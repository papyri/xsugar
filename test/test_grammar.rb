require 'test/unit'

require 'java'
require File.join(File.dirname(__FILE__), *%w".. lib xsugar-all.jar")
# require File.join(File.dirname(__FILE__), *%w".. lib grammar.jar")

module XSugar
  include_package 'dk.brics.xsugar'
end

module XSugarXML
  include_package 'dk.brics.xsugar.xml'
end

module XSugarParser
  include_package 'dk.brics.grammar.parser'
end

class GrammarTest < Test::Unit::TestCase
  charset = java.nio.charset.Charset.defaultCharset.name
  out = java.io.PrintWriter.new(java.lang.System.out, true)
  
  xsg_file = File.join(File.dirname(__FILE__), *%w".. epidoc.xsg")
  parser = XSugar::StylesheetParser.new
  xsg = File.readlines(xsg_file).to_s
  stylesheet = parser.parse(xsg, xsg_file, charset)
  XSugar::StylesheetChecker.new.check(stylesheet)
  
  grammar_builder = XSugar::GrammarBuilder.new(false)
  grammar_builder.convert(stylesheet)
  l_grammar = grammar_builder.getNonXMLGrammar
  x_grammar = grammar_builder.getXMLGrammar
  
  normalizing_grammar_builder = XSugar::GrammarBuilder.new(true)
  XSugarXML::StylesheetNormalizer.new.normalize(stylesheet)
  normalizing_grammar_builder.convert(stylesheet)
  normalized_l_grammar = normalizing_grammar_builder.getNonXMLGrammar
  normalized_x_grammar = normalizing_grammar_builder.getXMLGrammar
  
  parser_l = XSugarParser::Parser.new(l_grammar, out)
  parser_x = XSugarParser::Parser.new(normalized_x_grammar, out)
  
  def test_stub
    assert_equal 1, 1
  end
end