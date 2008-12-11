require 'test_helper'

class GrammarTest < Test::Unit::TestCase
  # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
  def test_expansion
    # Ancient abbreviation whose resolution is known
    assert_equal_fragment_transform 'a(b)', '<expan>a<ex>b</ex></expan>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
  def test_symbol_expansion
    # Single symbol for an entire word
    assert_equal_fragment_transform '(abc)', '<expan><ex>abc</ex></expan>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
  # http://www.stoa.org/epidoc/gl/5/numbersandnumerals.html
  # possibly: http://www.stoa.org/epidoc/gl/5/acrophonic.html
  def test_counting_symbol_expansion
    # A single symbol (one day representable in Unicode) was used to
    # indicate some number of things (usually monetary denominations)
    # The example used for this is 
    #  (ὀβολοὺς 3) = <expan><ex>ὀβολοὺς 3</ex></expan>
    # Which can also be represented by U+1017E = GREEK THREE OBOLS SIGN
    # To make things even more interesting, in existing DDb these are
    # tagged in the following ways:
    # * Closed XML num element following num text inside
    # monetary denomination expan (stud.pal.22.176 lb=9):
    #   <expan><ex>ὀβολοὺς 3</ex></expan><num value="3"/>
    # * XML num element with num text following monetary denomination expan
    # (stud.pal.22.180 lb=21):
    #   <expan><ex>ὀβολοὺς</ex></expan> <num value="8">η</num>
    # Then either of these methods used in conjunction with fractions
    # (upz.2.158 lb=29):
    #   <expan><ex>ὀβολοὺς 2 1/2 1/4</ex></expan><num value="2"/><num value="1/2"/><num value="1/4"/>
    # (sb.16.12325 lb=13):
    #   <expan><ex>ὀβολοὺς</ex></expan> <num value="3">γ</num> <num value="1/2">������</num>
    # And even other complex ways (sb.24.16185 lb=12):
    #   <expan><ex>ὀβολοὺς 4</ex><ex>ὀβολοῦ 1/2</ex></expan><num value="4"/><num value="1/2"/>
    # TODO: Get EpiDoc guidance on how this should be handled?
    assert_equal_fragment_transform '(abc 123)', '<expan><ex>abc 123</ex></expan>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/abbreviationsnotunderstood.html
  def test_abbreviation_unknown_resolution
    # Ancient abbreviation whose resolution is unknown
    assert_equal_fragment_transform 'ab( )', '<abbr>ab</abbr>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
  def test_abbreviation_uncertain_resolution
    # Ancient abbreviation whose resolution is uncertain
    assert_equal_fragment_transform '(abc?)', '<expan><ex cert="low">abc</ex></expan>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/lostcertain.html
  def test_lost_dot_gap
    # Some number of missing characters not greater than 3
    # TODO: [ca.N]
    assert_equal_fragment_transform '[.]', '<gap reason="lost" extent="1" unit="character"></gap>'
    assert_equal_fragment_transform '[.2]', '<gap reason="lost" extent="2" unit="character"></gap>'
    assert_equal_fragment_transform '[.3]', '<gap reason="lost" extent="3" unit="character"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/lostcertain.html
  # but extent="unknown" not explicitly combined with unit="character" in guidelines
  def test_lost_gap_unknown
    # Some unknown number of lost characters
    assert_equal_fragment_transform '[ca.?]', '<gap reason="lost" extent="unknown" unit="character"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/vestiges.html
  def test_illegible_dot_gap
    # Some number of illegible characters not greater than 3
    assert_equal_fragment_transform '.', '<gap reason="illegible" extent="1" unit="character"></gap>'
    assert_equal_fragment_transform '.2', '<gap reason="illegible" extent="2" unit="character"></gap>'
    assert_equal_fragment_transform '.3', '<gap reason="illegible" extent="3" unit="character"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/vestiges.html
  def test_illegible_gap_unknown
    # Some unknown number of illegible letters
    assert_equal_fragment_transform 'ca.?', '<gap reason="illegible" extent="unknown" unit="character"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/vestiges.html
  def test_illegible_gap_ca
    # Some number of illegible characters greater than 3
    assert_equal_fragment_transform 'ca.4', '<gap reason="illegible" extent="4" unit="character"></gap>'
    assert_equal_fragment_transform 'ca.5', '<gap reason="illegible" extent="5" unit="character"></gap>'
    assert_equal_fragment_transform 'ca.10', '<gap reason="illegible" extent="10" unit="character"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/vestiges.html
  # but no desc="vestiges"
  def test_vestige_lines
    # vestiges of N lines, mere smudges really, visible
    assert_equal_fragment_transform 'vestig.3lin', '<gap reason="illegible" extent="3" unit="line" desc="vestiges"></gap>'
    assert_equal_fragment_transform 'vestig.5lin', '<gap reason="illegible" extent="5" unit="line" desc="vestiges"></gap>'
    assert_equal_fragment_transform 'vestig.10lin', '<gap reason="illegible" extent="10" unit="line" desc="vestiges"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/vestiges.html
  # but no desc="vestiges"
  def test_vestige_lines_ca
    # vestiges of rough number of lines, mere smudges really, visible
    assert_equal_fragment_transform 'vestig.ca.3lin', '<gap reason="illegible" extent="3" unit="line" precision="circa" desc="vestiges"></gap>'
    assert_equal_fragment_transform 'vestig.ca.5lin', '<gap reason="illegible" extent="5" unit="line" precision="circa" desc="vestiges"></gap>'
    assert_equal_fragment_transform 'vestig.ca.10lin', '<gap reason="illegible" extent="10" unit="line" precision="circa" desc="vestiges"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/vestiges.html
  # should this have desc="vestiges"?
  def test_vestige_lines_unknown
    # vestiges of an unspecified number of lines, mere smudges, visible
    assert_equal_fragment_transform 'vestig.?lin', '<gap reason="illegible" extent="unknown" unit="line"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/vestiges.html
  # but no desc="vestiges"
  def test_vestige_characters
    # vestiges of an unspecified number of characters, mere smudges, visible
    assert_equal_fragment_transform 'vestig', '<gap reason="illegible" extent="unknown" unit="character" desc="vestiges"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/lostline.html
  def test_gap_break
    # The text breaks off completely
    assert_equal_fragment_transform 'BREAK', '<gap reason="lost" extent="unknown" unit="line"></gap>'
  end
  
  # FIXME: reconcile with test_lost_dot_gap
  def test_lost_characters
    # Some number of characters is lost
    assert_equal_fragment_transform 'lost.3char', '<gap reason="lost" extent="3" unit="character"></gap>'
    assert_equal_fragment_transform 'lost.5char', '<gap reason="lost" extent="5" unit="character"></gap>'
    assert_equal_fragment_transform 'lost.10char', '<gap reason="lost" extent="10" unit="character"></gap>'
  end
  
  # FIXME: reconcile with test_lost_gap_unknown
  def test_lost_characters_unknown
    # Some unknown number of lost characters
    assert_equal_fragment_transform 'lost.?char', '<gap reason="lost" extent="unknown" unit="character"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/lostline.html
  def test_lost_lines
    # Some number of lines is lost
    assert_equal_fragment_transform 'lost.3lin', '<gap reason="lost" extent="3" unit="line"></gap>'
    assert_equal_fragment_transform 'lost.5lin', '<gap reason="lost" extent="5" unit="line"></gap>'
    assert_equal_fragment_transform 'lost.10lin', '<gap reason="lost" extent="10" unit="line"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/lostline.html
  # FIXME: reconcile with test_gap_break
  def test_lost_lines_unknown
    # Some unknown number of lost lines
    assert_equal_fragment_transform 'lost.?lin', '<gap reason="lost" extent="unknown" unit="line"></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/erroneousomission.html
  def test_omitted
    # Scribe omitted character(s) and modern ed inserted it
    assert_equal_fragment_transform 'a<b>c', 'a<supplied reason="omitted">b</supplied>c'
    assert_equal_fragment_transform '<abc>', '<supplied reason="omitted">abc</supplied>'
    assert_equal_fragment_transform 'we will <we will> rock you', 'we will <supplied reason="omitted">we will</supplied> rock you'
    assert_equal_fragment_transform 'we ea<t the fi>sh', 'we ea<supplied reason="omitted">t the fi</supplied>sh'
  end
  
  # http://www.stoa.org/epidoc/gl/5/erroneousinclusion.html
  def test_sic
    # scribe wrote unnecessary characters and modern ed flagged them as such
    assert_equal_fragment_transform '{test}', '<sic>test</sic>'
    assert_equal_fragment_transform 'te{sting 1 2} 3', 'te<sic>sting 1 2</sic> 3'
  end
  
  # http://www.stoa.org/epidoc/gl/5/supplementforlost.html
  def test_lost
    # modern ed restores lost text
    assert_equal_fragment_transform '[abc]', '<supplied reason="lost">abc</supplied>'
    assert_equal_fragment_transform 'a[b]c', 'a<supplied reason="lost">b</supplied>c'
    assert_equal_fragment_transform 'a[bc def g]hi', 'a<supplied reason="lost">bc def g</supplied>hi'
  end
  
  # http://www.stoa.org/epidoc/gl/5/supplementforlost.html
  def test_lost_uncertain
    # modern ed restores lost text, with less than total confidence; this proved messy to handle in IDP1
    assert_equal_fragment_transform 'a[bc?]', 'a<supplied reason="lost" cert="low">bc</supplied>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/unclear.html
  def test_unicode_underdot_unclear
    # eds read dotted letter with less than full confidence
    # TODO: handle existing cert attributes
    # In the current DDB_EpiDoc_XML, only 1809/270095 unclear tags have a cert attribute
    # Those that do all have cert="low"
    assert_equal_fragment_transform 'ạ', '<unclear reason="undefined">a</unclear>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/unclear.html
  def test_unicode_underdot_unclear_combining
    # eds read dotted letter with less than full confidence
    assert_equal_fragment_transform 'ạḅc̣', '<unclear reason="undefined">abc</unclear>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/unclear.html
  # http://www.stoa.org/epidoc/gl/5/supplementforlost.html
  def test_unicode_underdot_unclear_combining_with_lost
    assert_equal_fragment_transform 'ạḅ[c̣ de]f', '<unclear reason="undefined">ab</unclear><supplied reason="lost"><unclear reason="undefined">c</unclear> de</supplied>f'
  end
  
  # http://www.stoa.org/epidoc/gl/5/deletion.html
  def test_ancient_erasure
    # ancient erasure/cancellation/expunction
    assert_equal_fragment_transform 'a[[bc]]', 'a<del rend="erasure">bc</del>'
    assert_equal_fragment_transform 'ab[[c def g]]hi', 'ab<del rend="erasure">c def g</del>hi'
  end
  
  # no EpiDoc guideline, inherited from TEI
  def test_quotation_marks
    # quotation marks on papyrus
    assert_equal_fragment_transform '"abc"', '<q>abc</q>'
    assert_equal_fragment_transform '"abc def ghi"', '<q>abc def ghi</q>'
  end
  
  def test_uncertain_diacritical_diaresis
    
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