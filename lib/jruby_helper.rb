module RXSugar
  module JRubyHelper
    if(RUBY_PLATFORM == 'java')
      require File.join(File.dirname(__FILE__), *%w'.. lib rxsugar')
      
      class RXSugarSingleton
        include Singleton
        include RXSugarHelper

        attr_reader :rxsugar

        def initialize
          @rxsugar = rxsugar_from_grammar(RXSugarHelper::DEFAULT_GRAMMAR)
        end
      end
      
      class TranslationRXSugarSingleton < RXSugarSingleton
        def initialize
          @rxsugar = rxsugar_from_grammar(RXSugarHelper::TRANSLATION_GRAMMAR)
        end
      end
      
      class CommentaryRXSugarSingleton < RXSugarSingleton
        def initialize
          @rxsugar = rxsugar_from_grammar(RXSugarHelper::COMMENTARY_GRAMMAR)
        end
      end
      
      
    end
    
    def self.included(base)
      base.extend(ActMethods)
    end
    
    require 'net/http'
    require 'uri'
    require 'json'
    
    class XSugarStandalone
      class << self
        def transform_request(url, params, retry_time = 0.00005)
          begin
            resp = Net::HTTP.post_form(URI.parse(url), params)
            if resp.code == '502'
              # Apache proxy error, retry
              sleep([retry_time, 1.0].min)
              return transform_request(url, params, retry_time * 2)
            elsif resp.code != '200'
              # Unexpected error, report
              error_type = params[:direction] == 'nonxml2xml' ? NonXMLParseError : XMLParseError
              raise error_type.new(0,0,params[:content]), "Error performing transform. Response code from web service: Error #{resp.code}. Response body: #{resp.body}"
            end
           
            parsed_resp = JSON.parse(resp.body)
            
            if parsed_resp.has_key?("exception")
              error_type = params[:direction] == 'nonxml2xml' ? NonXMLParseError : XMLParseError
              raise error_type.new(
                parsed_resp["exception"]["line"], parsed_resp["exception"]["column"], params[:content]),
                parsed_resp["exception"]["cause"]
            else
              return parsed_resp["content"]
            end
          rescue Errno::ECONNREFUSED, EOFError, Timeout::Error
            # retry after exponential backoff
            sleep([retry_time, 1.0].min)
            return transform_request(url, params, retry_time * 2)
          rescue JSON::ParserError => e
            # JSON parser error, received malformed JSON (e.g. mangled Unicode)
            error_type = params[:direction] == 'nonxml2xml' ? NonXMLParseError : XMLParseError
            raise error_type.new(0,0,params[:content]), "Error performing transform. JSON parser error: #{e.message}"
          end
        end
      end
    end
    
    module ActMethods
      def acts_as_x(x)
        unless included_modules.include? InstanceMethods
          if(RUBY_PLATFORM == 'java')
            extend RXSugarHelper
          end
          
          extend x
          include InstanceMethods
        end
      end
      
      def acts_as_leiden_plus
        acts_as_x LeidenPlusClassMethods
      end
      
      def acts_as_translation
        acts_as_x TranslationClassMethods
      end
      
    end
    
    module ClassMethods
      require 'drb/drb'
      require 'rinda/rinda'
      require 'rinda/ring'
      
      #----used for translation----
      def get_body(xml)  
        REXML::XPath.match(REXML::Document.new(xml), '/TEI/text/body/')        
      end
      
      def get_div_translation(xml)
        # new to pull from div type=translation for translation processing
        REXML::XPath.match(REXML::Document.new(xml), '/TEI/text/body/div[@type = "translation"]')
      end          
      #====end used for translation====      
      
      
      #----used for commentary---
      
      def wrap_commentary_sugar(commentary)
        return "<W " + commentary.strip + " W>"
      end
      def unwrap_commentary_sugar(commentary_sugar)
        commentary_sugar.sub!("<W", "")
        commentary_sugar.sub!("W>", "")
      end
      
      def wrap_commentary_xml(commentary_xml)
        return '<wrap>' + commentary_xml.strip + '</wrap>'
      end
      def unwrap_commentary_xml(commentary_xml)
       # commentary_xml.sub!( '<wrap>', "")
        commentary_xml.sub!( /<wrap(.*?)>/, "") # to catch any namespace additions
        commentary_xml.sub!( '</wrap>', "")
        
        #return REXML::XPath.first(REXML::Document.new(commentary_xml), '/wrap/*').to_s
      end
      
      
      #====end used for commentary====
      
      
      def preprocess_abs(abs)
        return "<div xml:lang=\"grc\" type=\"edition\" xml:space=\"preserve\">" + abs.to_s + "</div>"
      end
      
      def get_abs_from_edition_div(xml)
        REXML::XPath.match(REXML::Document.new(xml), '/TEI/text/body/div[@type = "edition"]/*')
      end
      
      def get_div_edition(xml)
        # new to pull from div edition on to get the get_non_lb_element_children xpath to work
        REXML::XPath.match(REXML::Document.new(xml), '/TEI/text/body/div[@type = "edition"]')
      end
      
      def parse_exception_pretty_print(text, position)
        carat = '^'.rjust(position)
        text + "\n" + carat
      end
      
      def xml2nonxml(content)
        # ruby_file = File.join(File.dirname(__FILE__), *%w'.. bin xml2nonxml.rb')
        # jruby_pipe(ruby_file, content)
        if((defined?(Sosol::Application) && Sosol::Application.config.respond_to?(:xsugar_standalone_enabled) && Sosol::Application.config.xsugar_standalone_enabled) || (defined?(XSUGAR_STANDALONE_ENABLED) && XSUGAR_STANDALONE_ENABLED))
          xformed = XSugarStandalone.transform_request(defined?(Sosol::Application) ? Sosol::Application.config.xsugar_standalone_url : XSUGAR_STANDALONE_URL,
            {
              :content => content,
              :type => transformer_name,
              :direction => 'xml2nonxml'
            }
          )
          return xformed.to_s
        elsif(RUBY_PLATFORM == 'java')
          begin
            xformed = transformer_singleton.instance.rxsugar.xml_to_non_xml(content)
            return xformed.to_s
          rescue NativeException => e
            parse_exception = e.cause()
            if parse_exception.class == Java::DkBricsGrammarParser::ParseException
              location = parse_exception.getLocation()
              raise XMLParseError.new(
                location.getLine(), location.getColumn(), content),
                parse_exception.getMessage()
            end
          end
        else
          return post_to_blackboard('xml', 'nonxml', content)
        end
      end
      
      def nonxml2xml(content)
        # ruby_file = File.join(File.dirname(__FILE__), *%w'.. bin nonxml2xml.rb')
        # jruby_pipe(ruby_file, content)
        if((defined?(Sosol::Application) && Sosol::Application.config.respond_to?(:xsugar_standalone_enabled) && Sosol::Application.config.xsugar_standalone_enabled) || (defined?(XSUGAR_STANDALONE_ENABLED) && XSUGAR_STANDALONE_ENABLED))
          xformed = XSugarStandalone.transform_request(defined?(Sosol::Application) ? Sosol::Application.config.xsugar_standalone_url : XSUGAR_STANDALONE_URL,
            {
              :content => content,
              :type => transformer_name,
              :direction => 'nonxml2xml'
            }
          )
          return xformed.to_s
        elsif(RUBY_PLATFORM == 'java')
          begin
            xformed = transformer_singleton.instance.rxsugar.non_xml_to_xml(content)
            return xformed.to_s
          rescue NativeException => e
            parse_exception = e.cause()
            if parse_exception.class == Java::DkBricsGrammarParser::ParseException
              location = parse_exception.getLocation()
              raise NonXMLParseError.new(
                location.getLine(), location.getColumn(), content),
                parse_exception.getMessage()
            end
          end
        else
          return post_to_blackboard('nonxml', 'xml', content)
        end
      end
      
      def jruby_pipe(ruby_file, content)
        IO.popen("jruby #{ruby_file}", "w+") do |pipe|
          pipe.puts content
          pipe.close_write
          pipe.read
        end
      end
      
      def post_to_blackboard(from, to, content)
        DRb.start_service
        # Just use the primary service, change this if we're going to register
        # any more services on the Ring Server
        ring_server = Rinda::RingFinger.primary
        
        tuplespace = ring_server.read([:name, :TupleSpace, nil, nil])[2]
        tuplespace = Rinda::TupleSpaceProxy.new tuplespace
        
        tuplespace.write([from, to, content, content.object_id])
        result, object_id, result_type, transformed = 
          tuplespace.take([:result, content.object_id, Symbol, String])
        DRb.stop_service
        
        if result_type == :exception
          raise transformed
        else
          return transformed
        end
      end
    end
    
    module LeidenPlusClassMethods
      def transformer_singleton
        RXSugarSingleton
      end
      
      def transformer_name
        "epidoc"
      end
      
      include ClassMethods
    end
    
    module TranslationClassMethods
      def transformer_singleton
        TranslationRXSugarSingleton
      end
      
      def transformer_name
        "translation_epidoc"
      end
      
      include ClassMethods
    end
    
    module CommentaryClassMethods
      def transformer_singleton
        CommentaryRXSugarSingleton
      end
      
      def transformer_name
        "commentary"
      end
      include ClassMethods
    end
    
    module InstanceMethods

    end

    class RXSugarProxy  
      def xml_to_non_xml(content)
        xml2nonxml(content)
      end
      
      def non_xml_to_xml(content)
        nonxml2xml(content)
      end
    end

    class LeidenPlusRXSugarProxy < RXSugarProxy
      include LeidenPlusClassMethods
    end
    
    class CommentaryRXSugarProxy < RXSugarProxy
      include CommentaryClassMethods
    end
         
  end
end
