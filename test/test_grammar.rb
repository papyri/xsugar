if(RUBY_PLATFORM == 'java')
  require File.join(File.dirname(__FILE__), 'test_helper')

  class GrammarTest < Test::Unit::TestCase
    # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
    def test_expansion
      # Ancient abbreviation whose resolution is known
      assert_equal_fragment_transform 'a(b)', '<expan>a<ex>b</ex></expan>'
    end
    
    def test_expansion_multiple
      assert_equal_fragment_transform 'ab(c)def(gh)i', '<expan>ab<ex>c</ex>def<ex>gh</ex>i</expan>'
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
      #   <expan><ex>ὀβολοὺς</ex></expan> <num value="3">γ</num> <num value="1/2">ŵ</num>
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
      # Some number of missing characters
      assert_equal_fragment_transform '[.1]', '<gap reason="lost" extent="1" unit="character"></gap>'
      assert_equal_fragment_transform '[.2]', '<gap reason="lost" extent="2" unit="character"></gap>'
      assert_equal_fragment_transform '[.3]', '<gap reason="lost" extent="3" unit="character"></gap>'
      (4..100).each do |n|
        assert_equal_fragment_transform "[.#{n}]", "<gap reason=\"lost\" extent=\"#{n}\" unit=\"character\"></gap>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/lostcertain.html
    # but extent="unknown" not explicitly combined with unit="character" in guidelines
    def test_lost_gap_unknown
      # Some unknown number of lost characters
      assert_equal_fragment_transform '[.?]', '<gap reason="lost" extent="unknown" unit="character"></gap>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    def test_illegible_dot_gap
      # Some number of illegible characters not greater than 3
      assert_equal_fragment_transform '.1', '<gap reason="illegible" extent="1" unit="character"></gap>'
      assert_equal_fragment_transform '.2', '<gap reason="illegible" extent="2" unit="character"></gap>'
      assert_equal_fragment_transform '.3', '<gap reason="illegible" extent="3" unit="character"></gap>'
      (4..100).each do |n|
        assert_equal_fragment_transform ".#{n}", "<gap reason=\"illegible\" extent=\"#{n}\" unit=\"character\"></gap>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    def test_illegible_gap_unknown
      # Some unknown number of illegible letters
      assert_equal_fragment_transform '.?', '<gap reason="illegible" extent="unknown" unit="character"></gap>'
    end
    
    def test_illegible_dot_gap_extentmax
      assert_equal_fragment_transform '.2-3', '<gap reason="illegible" extent="2" extentmax="3" unit="character"></gap>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    # but no desc="vestiges"
    def test_vestige_lines
      # vestiges of N lines, mere smudges really, visible
      assert_equal_fragment_transform 'vestig.3lin', '<gap reason="illegible" extent="3" unit="line" desc="vestiges"></gap>'
      (1..100).each do |n|
        assert_equal_fragment_transform "vestig.#{n}lin", "<gap reason=\"illegible\" extent=\"#{n}\" unit=\"line\" desc=\"vestiges\"></gap>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    # but no desc="vestiges"
    def test_vestige_lines_ca
      # vestiges of rough number of lines, mere smudges really, visible
      assert_equal_fragment_transform 'vestig.ca.3lin', '<gap reason="illegible" extent="3" unit="line" precision="circa" desc="vestiges"></gap>'
      (1..100).each do |n|
        assert_equal_fragment_transform "vestig.ca.#{n}lin", "<gap reason=\"illegible\" extent=\"#{n}\" unit=\"line\" precision=\"circa\" desc=\"vestiges\"></gap>"
      end
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
    def test_lost_lines
      # Some number of lines is lost
      assert_equal_fragment_transform 'lost.3lin', '<gap reason="lost" extent="3" unit="line"></gap>'
      (1..100).each do |n|
        assert_equal_fragment_transform "lost.#{n}lin", "<gap reason=\"lost\" extent=\"#{n}\" unit=\"line\"></gap>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/lostline.html
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
    
    def test_omitted_cert_low
      assert_equal_fragment_transform '<τοῦ?>', '<supplied reason="omitted" cert="low">τοῦ</supplied>'
    end
    
    def test_evidence_parallel
      assert_equal_fragment_transform '_ς ἐπιστολῆς Θεοδώρου_', '<supplied reason="undefined" evidence="parallel">ς ἐπιστολῆς Θεοδώρου</supplied>'
    end
    
    def test_evidence_parallel_cert_low
      assert_equal_fragment_transform '_ς ἐπιστολῆς Θεοδώρου?_', '<supplied reason="undefined" evidence="parallel" cert="low">ς ἐπιστολῆς Θεοδώρου</supplied>'
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
  
    def test_uncertain_diacritical_diaeresis
      # Google Doc has U+00AD = soft hyphen before U+00A8 = diaeresis
      # RB notes: I have dropped the soft hyphen
      assert_equal_fragment_transform 'a(¨)bc', '<hi rend="diaeresis">a</hi>bc'
      # test with precombined unicode just to be sure
      assert_equal_fragment_transform 'Ἰ(¨)ουστινιανοῦ', '<hi rend="diaeresis">Ἰ</hi>ουστινιανοῦ'
    end
  
    def test_uncertain_diacritical_varia
      assert_equal_fragment_transform 'abcde(`)f', 'abcd<hi rend="varia">e</hi>f'
    end
  
    def test_uncertain_diacritical_oxia
      assert_equal_fragment_transform 'abcde(΄)f', 'abcd<hi rend="oxia">e</hi>f'
    end
  
    def test_uncertain_diacritical_dasia
      assert_equal_fragment_transform 'a(῾)bcdef', '<hi rend="dasia">a</hi>bcdef'
    end
  
    def test_uncertain_diacritical_psili
      assert_equal_fragment_transform 'a(᾿)bcdef', '<hi rend="psili">a</hi>bcdef'
    end
  
    def test_uncertain_diacritical_perispomeni
      assert_equal_fragment_transform 'a(῀)bcdef', '<hi rend="perispomeni">a</hi>bcdef'
    end
    
    def test_num_simple
      assert_equal_fragment_transform '<#α=1#>', '<num value="1">α</num>'
      assert_equal_fragment_transform '<#α=#>', '<num>α</num>'
      assert_equal_fragment_transform '<#=1#>', '<num value="1"></num>'
      assert_equal_fragment_transform '<#δ=1/4#>', '<num value="1/4">δ</num>'
      assert_equal_fragment_transform '<#ιδ=14#>', '<num value="14">ιδ</num>'
    end
    
    def test_num_myriads
      assert_equal_fragment_transform '<#μυρίαδες<#β=2#><#Βφ=2500#>=22500#>', '<num value="22500">μυρίαδες<num value="2">β</num><num value="2500">Βφ</num></num>'
    end
    
    def test_choice
      assert_equal_fragment_transform '<:a|orth|b:>', '<choice><corr>a</corr><sic>b</sic></choice>'
      assert_equal_fragment_transform '<:a|orth|<:b|orth|c:>:>', '<choice><corr>a</corr><sic><choice><corr>b</corr><sic>c</sic></choice></sic></choice>'
    end
    
    def test_glyph
      assert_equal_fragment_transform '!!stauros', '<g type="stauros"></g>'
      assert_equal_fragment_transform '!!stauros,♱', '<g type="stauros">♱</g>'
      assert_equal_fragment_transform '!!filler(extension)', '<g type="filler" rend="extension"></g>'
    end
    
    def test_hand_shift
      assert_equal_fragment_transform '$m1', '<handShift new="m1"></handShift>'
      assert_equal_fragment_transform '$m20', '<handShift new="m20"></handShift>' 
    end
  
    def test_simple_reversibility
      assert_equal_non_xml_to_xml_to_non_xml "1. test", "1. test"
      assert_equal_non_xml_to_xml_to_non_xml "1. test1\n2. test2", "1. test1\n2. test2"
    end
  
    def test_line_numbering_reversibility_exhaustive
      (1..100).each do |num_lines|
        str = ''
        (1..num_lines).each do |this_line|
          str += "#{this_line}. test#{this_line}\n"
        end
        str.chomp!
        assert_equal_non_xml_to_xml_to_non_xml str, str
      end
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
end