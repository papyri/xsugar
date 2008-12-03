require 'test/unit'

require 'java'
require File.join(File.dirname(__FILE__), *%w".. lib xsugar-all.jar")

module XSugar
  include_package 'dk.brics.xsugar'
end

class GrammarTest < Test::Unit::TestCase
  charset = java.nio.charset.Charset.defaultCharset.name
  xsg_file = File.join(File.dirname(__FILE__), *%w".. epidoc.xsg")
  parser = XSugar::StylesheetParser.new
  xsg = File.readlines(xsg_file).to_s
  stylesheet = parser.parse(xsg, xsg_file, charset)
  
  def test_stub
    assert_equal 1, 1
  end
end