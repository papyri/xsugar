module RXSugar
  module JRubyHelper
    DRB_SERVER_URI = 'druby://172.16.42.35:9001'
    RESULT_IDENTIFIER = 'result'
    
    def self.included(base)
      base.extend(ActMethods)
    end
    
    module ActMethods
      def acts_as_leiden_plus
        unless included_modules.include? InstanceMethods
          extend ClassMethods
          include InstanceMethods
        end
      end
    end
    
    module ClassMethods
      require 'drb/drb'
      require 'rinda/rinda'
      
      def preprocess_abs(abs)
        return "<wrapab>" + abs.to_s + "</wrapab>"
      end
      
      def get_abs_from_edition_div(xml)
        REXML::XPath.match(REXML::Document.new(xml), '/TEI.2/text/body/div[@type = "edition"]//ab')
      end
      
      def parse_exception_pretty_print(text, position)
        carat = '^'.rjust(position)
        text + "\n" + carat
      end
      
      def xml2nonxml(content)
        # ruby_file = File.join(File.dirname(__FILE__), *%w'.. bin xml2nonxml.rb')
        # jruby_pipe(ruby_file, content)
        post_to_blackboard('xml', 'nonxml', content)
      end
      
      def nonxml2xml(content)
        # ruby_file = File.join(File.dirname(__FILE__), *%w'.. bin nonxml2xml.rb')
        # jruby_pipe(ruby_file, content)
        post_to_blackboard('nonxml', 'xml', content)
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
        tuplespace = Rinda::TupleSpaceProxy.new(DRbObject.new(nil, 
                                                DRB_SERVER_URI))
        tuplespace.write([from, to, content])
        result, result_type, transformed = 
          tuplespace.take([RESULT_IDENTIFIER, nil])
        DRb.stop_service
        
        if transformed.class == NativeException
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