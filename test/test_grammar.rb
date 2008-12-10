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
  
  def test_abbreviation_uncertain_resolution
    # Ancient abbreviation whose resolution is uncertain
    assert_equal_fragment_transform '(abc?)', '<expan><ex cert="low">abc</ex></expan>'
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
  
  def test_vestige_lines
    # vestiges of N lines, mere smudges really, visible
    assert_equal_fragment_transform 'vestig.3lin', '<gap reason="illegible" extent="3" unit="line" desc="vestiges"></gap>'
    assert_equal_fragment_transform 'vestig.5lin', '<gap reason="illegible" extent="5" unit="line" desc="vestiges"></gap>'
    assert_equal_fragment_transform 'vestig.10lin', '<gap reason="illegible" extent="10" unit="line" desc="vestiges"></gap>'
  end
  
  def test_vestige_lines_ca
    # vestiges of rough number of lines, mere smudges really, visible
    assert_equal_fragment_transform 'vestig.ca.3lin', '<gap reason="illegible" extent="3" unit="line" precision="circa" desc="vestiges"></gap>'
    assert_equal_fragment_transform 'vestig.ca.5lin', '<gap reason="illegible" extent="5" unit="line" precision="circa" desc="vestiges"></gap>'
    assert_equal_fragment_transform 'vestig.ca.10lin', '<gap reason="illegible" extent="10" unit="line" precision="circa" desc="vestiges"></gap>'
  end
  
  def test_vestige_lines_unknown
    # vestiges of an unspecified number of lines, mere smudges, visible
    assert_equal_fragment_transform 'vestig.?lin', '<gap reason="illegible" extent="unknown" unit="line"></gap>'
  end
  
  def test_vestige_characters
    # vestiges of an unspecified number of characters, mere smudges, visible
    assert_equal_fragment_transform 'vestig', '<gap reason="illegible" extent="unknown" unit="character" desc="vestiges"></gap>'
  end
  
  def test_gap_break
    # The text breaks off completely
    assert_equal_fragment_transform 'BREAK', '<gap reason="lost" extent="unknown" unit="line"></gap>'
  end
  
  def test_lost_characters
    # Some number of characters is lost
    assert_equal_fragment_transform 'lost.3char', '<gap reason="lost" "extent="3" unit="character"></gap>'
    assert_equal_fragment_transform 'lost.5char', '<gap reason="lost" "extent="5" unit="character"></gap>'
    assert_equal_fragment_transform 'lost.10char', '<gap reason="lost" "extent="10" unit="character"></gap>'
  end
  
  def test_lost_characters_unknown
    # Some unknown number of lost characters
    assert_equal_fragment_transform 'lost.?char', '<gap reason="lost" "extent="unknown" unit="character"></gap>'
  end
  
  def test_lost_lines
    # Some number of lines is lost
    assert_equal_fragment_transform 'lost.3lin', '<gap reason="lost" "extent="3" unit="line"></gap>'
    assert_equal_fragment_transform 'lost.5lin', '<gap reason="lost" "extent="5" unit="line"></gap>'
    assert_equal_fragment_transform 'lost.10lin', '<gap reason="lost" "extent="10" unit="line"></gap>'
  end
  
  def test_lost_lines_unknown
    # Some unknown number of lost lines
    assert_equal_fragment_transform 'lost.?lin', '<gap reason="lost" "extent="unknown" unit="line"></gap>'
  end
  
  def test_omitted
    # Scribe omitted character(s) and modern ed inserted it
    assert_equal_fragment_transform 'a<b>c', 'a<supplied reason="omitted">b</supplied>c'
    assert_equal_fragment_transform '<abc>', '<supplied reason="omitted">abc</supplied>'
  end
  
  def test_sic
    # scribe wrote unnecessary characters and modern ed flagged them as such
    assert_equal_fragment_transform '{test}', '<sic>test</sic>'
  end
  
  def test_lost
    # modern ed restores lost text
    # TODO: tests for στ[ρατηγός or στρατ]ηγός examples
    # Are those intended to close on word/line breaks, or span them?
    assert_equal_fragment_transform '[abc]', '<supplied reason="lost">abc</supplied>'
    assert_equal_fragment_transform 'a[b]c', 'a<supplied reason="lost">b</supplied>c'
  end
  
  def test_lost_uncertain
    # modern ed restores lost text, with less than total confidence; this proved messy to handle in IDP1
    assert_equal_fragment_transform 'a[bc?]', 'a<supplied reason="lost" cert="low">bc</supplied>'
  end

  def test_unicode_underdot_unclear
    # eds read dotted letter with less than full confidence
    # TODO: handle existing cert attributes
    # In the current DDB_EpiDoc_XML, only 1809/270095 unclear tags have a cert attribute
    # Those that do all have cert="low"
    assert_equal_fragment_transform 'ạ', '<unclear reason="undefined">a</unclear>'
  end
  
  def test_unicode_underdot_unclear_combining
    # eds read dotted letter with less than full confidence
    assert_equal_fragment_transform 'ạḅc̣', '<unclear reason="undefined">abc</unclear>'
  end
  
  def test_ancient_erasure
    # ancient erasure/cancellation/expunction
    assert_equal_fragment_transform 'a[[bc]]', 'a<del rend="erasure">bc</del>'
  end
  
  def test_quotation_marks
    # quotation marks on papyrus
    assert_equal_fragment_transform '"abc"', '<q>abc</q>'
  end
  
  def test_simple_reversibility
    assert_equal_non_xml_to_xml_to_non_xml "1. test", "1. test"
    assert_equal_non_xml_to_xml_to_non_xml "1. test1\n2. test2", "1. test1\n2. test2"
  end
  
  def test_xml_trailing_newline_stripped
    assert_equal_non_xml_to_xml_to_non_xml "1. test", "1. test\n"
    assert_equal_non_xml_to_xml_to_non_xml "1. test1\n2. test2", "1. test1\n2. test2\n"
  end
  
  def test_unicode_greek_reversibility
    assert_equal_non_xml_to_xml_to_non_xml '1. ςερτυθιοπασδφγηξκλζχψωβνμ', '1. ςερτυθιοπασδφγηξκλζχψωβνμ'
  end
  
  def test_xsugar_reversibility_true
    assert @xsugar.reversible?
  end
end