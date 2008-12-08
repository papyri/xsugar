require 'test_helper'

class GrammarTest < Test::Unit::TestCase
  def test_expansion
    # Ancient abbreviation whose resolution is known
    # CHET-C expands this to <expan>a<supplied reason="abbreviation">b</supplied></expan>
    assert_equal_fragment_transform 'a(b)', '<expan>a<ex cert="high">b</ex></expan>'
  end
  
  def test_symbol_expansion
    # Single symbol for an entire word
    assert_equal_fragment_transform '(abc)', '<expan><ex>abc</ex></expan>'
  end
  
  def test_ambiguous_symbol_expansion
    # A single symbol (one day representable in Unicode) was used to
    # indicate some number of things (usually monetary denominations)
    assert_equal_fragment_transform '(abc 123)', '<expan><ex>abc 123</ex></expan>'
  end
  
  def test_abbreviation_unknown_resolution
    # Ancient abbreviation whose resolution is unknown
    assert_equal_fragment_transform 'ab( )', '<abbr>ab</abbr>'
  end
  
  def test_lost_dot_gap
    # Some number of missing characters not greater than 3
    # TODO: [ca.N]
    assert_equal_fragment_transform '[.]', '<gap reason="lost" extent="1" unit="character"></gap>'
    assert_equal_fragment_transform '[.2]', '<gap reason="lost" extent="2" unit="character"></gap>'
    assert_equal_fragment_transform '[.3]', '<gap reason="lost" extent="3" unit="character"></gap>'
  end
  
  def test_lost_gap_unknown
    # Some unknown number of lost characters
    assert_equal_fragment_transform '[ca.?]', '<gap reason="lost" extent="unknown" unit="character"></gap>'
  end
  
  def test_illegible_dot_gap
    # Some number of illegible characters not greater than 3
    assert_equal_fragment_transform '.', '<gap reason="illegible" extent="1" unit="character"></gap>'
    assert_equal_fragment_transform '.2', '<gap reason="illegible" extent="2" unit="character"></gap>'
    assert_equal_fragment_transform '.3', '<gap reason="illegible" extent="3" unit="character"></gap>'
  end
  
  def test_illegible_gap_unknown
    # Some unknown number of illegible letters
    assert_equal_fragment_transform 'ca.?', '<gap reason="illegible" extent="unknown" unit="character"></gap>'
  end
  
  def test_illegible_gap_ca
    # Some number of illegible characters greater than 3
    assert_equal_fragment_transform 'ca.4', '<gap reason="illegible" extent="4" unit="character"></gap>'
    assert_equal_fragment_transform 'ca.5', '<gap reason="illegible" extent="5" unit="character"></gap>'
    assert_equal_fragment_transform 'ca.10', '<gap reason="illegible" extent="10" unit="character"></gap>'
  end

  def test_unicode_underdot_unclear
    assert_equal_fragment_transform 'ạ', '<unclear reason="undefined" cert="high">a</unclear>'
  end
  
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
  
  def test_xsugar_reversibility_true
    assert @xsugar.reversible?
  end
end