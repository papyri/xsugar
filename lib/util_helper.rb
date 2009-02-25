require File.join(File.dirname(__FILE__), 'rxsugar')

module RXSugar
  class UtilHelper
    include RXSugarHelper
    
    def initialize(from, to)
      @from_file = STDIN
      @grammar_file = RXSugarHelper::DEFAULT_GRAMMAR
      @from = from
      @to = to
    end
  
    def processargs
      if ARGV.length >= 1 && ARGV[0] == '--help'
        puts "Usage: #{$0} < input.#{@from} > output.#{@to}\n" +
             "       #{$0} grammar.xsg < input.#{@from} > output.#{@to}\n" +
             "       #{$0} grammar.xsg input.#{@from} > output.#{@to}"
        Process.exit
      end

      if ARGV.length >= 1
        @grammar_file = ARGV[0]
        if ARGV.length >= 2
          @from_file = ARGV[1]
        end
      end
    end

    def main
      processargs
    
      if @from == 'xml'
        xml_file_to_non_xml(@from_file, @grammar_file)
      else
        non_xml_file_to_xml(@from_file, @grammar_file)
      end
    end
  end
end