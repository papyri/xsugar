require 'java'
require File.join(File.dirname(__FILE__), *%w".. lib xsugar-all.jar")

class RXSugar
  module XSugar
    include_package 'dk.brics.xsugar'
  end

  module XSugarXML
    include_package 'dk.brics.xsugar.xml'
  end

  module XSugarParser
    include_package 'dk.brics.grammar.parser'
  end

  module XSugarOperations
    include_package 'dk.brics.grammar.operations'
  end

  def initialize(grammar)
    # Most of this is taken from XSugar source in
    # src/dk/brics/xsugar/Main.java
    charset = java.nio.charset.Charset.defaultCharset.name
    out = java.io.PrintWriter.new(java.lang.System.out, true)

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

    @parser_l = XSugarParser::Parser.new(@l_grammar, out)
    @parser_x = XSugarParser::Parser.new(@normalized_x_grammar, out)
  end

  def non_xml_to_xml(text)
    begin
      ast = @parser_l.parse(text, 'dummy.txt')
      output = XSugarOperations::Unparser.new(@x_grammar).unparse(ast)
      output = XSugarXML::EndTagNameAdder.new.fix(output)
      output = XSugarXML::NamespaceAdder.new(@stylesheet).fix(output)
      return output
    rescue NativeException => e
      return e.cause
    end
  end

  def xml_to_non_xml(xml)
    norm = XSugarXML::InputNormalizer.new
    input = norm.normalize(xml, 'dummy.xml')
    begin
      ast = @parser_x.parse(input, 'dummy.xml')
      XSugarXML::ASTUnescaper.new.unescape(ast)
      output = XSugarOperations::Unparser.new(@normalized_l_grammar).unparse(ast)
      return output
    rescue NativeException => e
      return e.cause
    end
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