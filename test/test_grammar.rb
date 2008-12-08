require 'test_helper'

class GrammarTest < Test::Unit::TestCase
  def test_simple_reversibility
    assert_equal "test", @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test"))
    assert_equal "test1\ntest2", @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test1\ntest2"))
  end
  
  def test_xml_trailing_newline_stripped
    assert_equal "test", @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test\n"))
    assert_equal "test1\ntest2", @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test1\ntest2\n"))
  end
  
  def test_sic
    assert_equal_fragment_transform "<sic>test</sic>", "test(!)"
  end
end