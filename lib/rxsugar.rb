require File.join(File.dirname(__FILE__), 'rxsugar_helper')

module RXSugar
  class ParseError < ::StandardError
    attr_reader :line, :column, :content
    def initialize(line = 0, column = 0, content = "")
      @line = line
      @column = column
      @content = content
    end
  end
  class XMLParseError < ParseError; end
  class NonXMLParseError < ParseError; end
  
  if(RUBY_PLATFORM == 'java')
    require 'java'
    require RXSugarHelper::XSUGAR_JAR_PATH
    require File.join(File.dirname(__FILE__), 'modules_jruby')
  else
    begin
      require 'rubygems'
      require 'rjb'
      Rjb::load(classpath = ".:#{RXSugarHelper::XSUGAR_JAR_PATH}", jvmargs=[])
      require File.join(File.dirname(__FILE__), 'modules_rjb')
    rescue LoadError, RuntimeError
      # We aren't running inside JRuby, and we either don't have RJB 
      # or can't load the XSugar JAR because it's Java 6.
      # Punt and try to fork a JRuby child then provide the same RXSugar
      # interface over it.
    end
  end
  
  class RXSugar
    def initialize(grammar)
      # Most of this is taken from XSugar source in
      # src/dk/brics/xsugar/Main.java
      # charset = java.nio.charset.Charset.defaultCharset.name
      charset = java.nio.charset.Charset.forName("UTF-8").name
    
      @out = java.io.PrintWriter.new(java.lang.System.out, true)
      @verbose = false

      parser = XSugar::StylesheetParser.new
      @stylesheet = parser.parse(grammar, 'dummy.xsg', charset)
      XSugar::StylesheetChecker.new.check(@stylesheet)

      grammar_builder = XSugar::GrammarBuilder.new(false)
      grammar_builder.convert(@stylesheet)
      @l_grammar = grammar_builder.getNonXMLGrammar
      @x_grammar = grammar_builder.getXMLGrammar

      normalizing_grammar_builder = XSugar::GrammarBuilder.new(true)
      XSugarXML::StylesheetNormalizer.new.normalize(@stylesheet)
      normalizing_grammar_builder.convert(@stylesheet)
      @normalized_l_grammar = normalizing_grammar_builder.getNonXMLGrammar
      @normalized_x_grammar = normalizing_grammar_builder.getXMLGrammar

      @parser_l = XSugarParser::Parser.new(@l_grammar, @out)
      @parser_x = XSugarParser::Parser.new(@normalized_x_grammar, @out)
    end

    def non_xml_to_xml(text)
        ast = @parser_l.parse(text, 'dummy.txt')
        output = XSugarOperations::Unparser.new(@x_grammar).unparse(ast)
        output = XSugarXML::EndTagNameAdder.new.fix(output)
        output = XSugarXML::NamespaceAdder.new(@stylesheet).fix(output)
        return output
    end

    def xml_to_non_xml(xml)
      norm = XSugarXML::InputNormalizer.new
      input = norm.normalize(xml, 'dummy.xml')

        ast = @parser_x.parse(input, 'dummy.xml')
        XSugarXML::ASTUnescaper.new.unescape(ast)
        output = XSugarOperations::Unparser.new(@normalized_l_grammar).unparse(ast)
        return output
    end
  
    def reversible?
      reversibility_checker = XSugarReversibility::ReversibilityChecker.new(@out, @verbose)
      reversibility_checker.check(@normalized_l_grammar, @normalized_x_grammar,
        0, '', '', false)
    end
  
    def print_grammars
      puts "Left-hand-side grammar:"
      puts @l_grammar
      puts "Right-hand-side grammar:"
      puts @x_grammar
      puts "Normalized left-hand-side grammar:"
      puts @normalized_l_grammar
      puts "Normalized right-hand-side grammar:"
      puts @normalized_x_grammar
    end
  end
end