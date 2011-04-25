require 'lib/rxsugar'
require 'lib/jruby_helper'

require 'rubygems'
require 'progressbar'

module RXSugar
  module Standalone
    class Runner
      def saxon_command(xsl)
        return "java -classpath #{SAXON_JAR} net.sf.saxon.Transform - #{xsl}"
      end
      
      def preprocess_xml(xml_filename)
        command_string = "cat #{xml_filename}"
        saxon_commands = XSL_CHAIN.collect{|xsl| " | " + saxon_command(xsl)}.join('')
        command_string = command_string + saxon_commands
        
        result = `#{command_string}`
        
        return result
      end
      
      def run
        xml_files = Dir[DATA_PATH + '/**/*.xml']
        xml_files_bar = ProgressBar.new("files", xml_files.length)
        
        xml_files.each do |xml_file|
          # xml_content = IO.readlines(xml_file).to_s
          xml_content = preprocess_xml(xml_file)
          
          begin
            nonxml_content = JRubyHelper::XSugarStandalone.transform_request(
              STANDALONE_URL,
              {
                :content => xml_content,
                :type => GRAMMAR_STRING,
                :direction => 'xml2nonxml'
              }
            )
            JRubyHelper::XSugarStandalone.transform_request(
              STANDALONE_URL,
              {
                :content => nonxml_content,
                :type => GRAMMAR_STRING,
                :direction => 'nonxml2xml'
              }
            )
          rescue XMLParseError, NonXMLParseError
          end
            
          xml_files_bar.inc
        end
        xml_files_bar.finish
      end
    end
  end
end