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
    assert_equal_non_xml_to_xml_to_non_xml 'ςερτυθιοπασδφγηξκλζχψωβνμ', 'ςερτυθιοπασδφγηξκλζχψωβνμ'
  end
  
  def test_sic
    assert_equal_fragment_transform '<sic>test</sic>', 'test(!)'
  end

  def test_single_dot_gap
    assert_equal_fragment_transform '<gap extent="1"></gap>', '.'
  end
  
  def test_expansion
    # Ancient abbreviation whose resolution is known
    # This is how CHET-C transforms it, though the spreadsheet suggests simply <expan>a<ex>b</ex></expan>
    assert_equal_fragment_transform '<expan>a<supplied reason="abbreviation">b</supplied></expan>', 'a(b)'
  end

  def test_damage_unicode_underdot
    assert_equal_fragment_transform '<unclear reason="damage" cert="high">a</unclear>', 'ạ'
  end

  def test_bracket_gap
    assert_equal_fragment_transform 'a<supplied reason="omitted">b</supplied>c', 'a<b>c'
  end
end