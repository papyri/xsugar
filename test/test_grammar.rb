require 'test_helper'

class GrammarTest < Test::Unit::TestCase
  def test_simple_reversibility
    assert_equal_non_xml_to_xml_to_non_xml "test", "test"
    assert_equal_non_xml_to_xml_to_non_xml "test1\ntest2", "test1\ntest2"
  end
  
  def test_xml_trailing_newline_stripped
    assert_equal_non_xml_to_xml_to_non_xml "test", "test\n"
    assert_equal_non_xml_to_xml_to_non_xml "test1\ntest2", "test1\ntest2\n"
  end
  
  def test_unicode_greek_reversibility
    assert_equal_non_xml_to_xml_to_non_xml "ςερτυθιοπασδφγηξκλζχψωβνμ", "ςερτυθιοπασδφγηξκλζχψωβνμ"
  end
  
  def test_sic
    assert_equal_fragment_transform "<sic>test</sic>", "test(!)"
  end
  
  def test_bracket_gap
    assert_equal_fragment_transform "a<supplied reason=\"omitted\">b</supplied>c", "a<b>c"
  end
end