require 'test/unit'

require 'java'
require File.join(File.dirname(__FILE__), *%w".. lib xsugar-all.jar")

module XSugar
  include_package 'dk.brics.xsugar'
end

class GrammarTest < Test::Unit::TestCase
  parser = XSugar::StylesheetParser.new
  
  def test_stub
    assert_equal 1, 1
  end
end