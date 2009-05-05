module RXSugar
  module JRubyHelper
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
      
    end
    
    module InstanceMethods
      def parse_exception_pretty_print(text, position)
        carat = '^'.rjust(position)
        text + "\n" + carat
      end
      
      def xml2nonxml(content)
        ruby_file = File.join(File.dirname(__FILE__), *%w'.. bin xml2nonxml.rb')
        jruby_pipe(ruby_file, content)
      end
      
      def nonxml2xml(content)
        ruby_file = File.join(File.dirname(__FILE__), *%w'.. bin nonxml2xml.rb')
        jruby_pipe(ruby_file, content)
      end
            
      def jruby_pipe(ruby_file, content)
        IO.popen("jruby #{ruby_file}", "w+") do |pipe|
          pipe.puts content
          pipe.close_write
          pipe.read
        end
      end
    end
    
  end
end