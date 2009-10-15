module RXSugar
  module JRubyHelper
    def self.included(base)
      base.extend(ActMethods)
    end
    
    module ActMethods
      def acts_as_leiden_plus
        unless included_modules.include? InstanceMethods
          if(RUBY_PLATFORM == 'java')
            require File.join(File.dirname(__FILE__), *%w'.. lib rxsugar')
            extend RXSugarHelper
          end
          
          extend ClassMethods
          include InstanceMethods
        end
      end
    end
    
    module ClassMethods
      require 'drb/drb'
      require 'rinda/rinda'
      require 'rinda/ring'
      
      def preprocess_abs(abs)
        return "<wrapab>" + abs.to_s + "</wrapab>"
      end
      
      def get_abs_from_edition_div(xml)
        #REXML::XPath.match(REXML::Document.new(xml), '/TEI.2/text/body/div[@type = "edition"]//ab')
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
        if(RUBY_PLATFORM == 'java')
          rxsugar ||= rxsugar_from_grammar(RXSugarHelper::DEFAULT_GRAMMAR)
          return rxsugar.xml_to_non_xml(content).to_s
        else
          return post_to_blackboard('xml', 'nonxml', content)
        end
      end
      
      def nonxml2xml(content)
        # ruby_file = File.join(File.dirname(__FILE__), *%w'.. bin nonxml2xml.rb')
        # jruby_pipe(ruby_file, content)
        if(RUBY_PLATFORM == 'java')
          rxsugar ||= rxsugar_from_grammar(RXSugarHelper::DEFAULT_GRAMMAR)
          return rxsugar.non_xml_to_xml(content).to_s
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
    
    module InstanceMethods

    end
    
  end
end