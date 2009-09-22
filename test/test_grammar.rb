if(RUBY_PLATFORM == 'java')
  require File.join(File.dirname(__FILE__), 'test_helper')

  class GrammarTest < Test::Unit::TestCase
    # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
    def test_expansion
      # Ancient abbreviation whose resolution is known
      assert_equal_fragment_transform '<+a(b)+>', '<expan>a<ex>b</ex></expan>'
    end
    
    def test_expansion_multiple
	  #commented out test case below - not sure valid
      #assert_equal_fragment_transform '<+ab(c)def(gh)i+>', '<expan>ab<ex>c</ex>def<ex>gh</ex>i</expan>'
	  assert_equal_fragment_transform '<+ab(c)def(gh)i(j)+>', '<expan>ab<ex>c</ex>def<ex>gh</ex>i<ex>j</ex></expan>'
    end
    
    def test_expansion_with_supp
      assert_equal_fragment_transform 'abc[def] <+[gh]i(jk)+>', 'abc<supplied reason="lost">def</supplied> <expan><supplied reason="lost">gh</supplied>i<ex>jk</ex></expan>'
      assert_equal_fragment_transform '<+a[b(cd)]+>', '<expan>a<supplied reason="lost">b<ex>cd</ex></supplied></expan>'
      assert_equal_fragment_transform '<+[(eton)]+>', '<expan><supplied reason="lost"><ex>eton</ex></supplied></expan>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
    def test_symbol_expansion
      # Single symbol for an entire word
      assert_equal_fragment_transform '<+(abc)+>', '<expan><ex>abc</ex></expan>'
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
      assert_equal_fragment_transform '<+(abc 123)+>', '<expan><ex>abc 123</ex></expan>'
	  #assert_equal_fragment_transform '(abc 123)', '<expan><ex>abc 123</ex></expan>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/abbreviationsnotunderstood.html
    def test_abbreviation_unknown_resolution
      # Ancient abbreviation whose resolution is unknown
      assert_equal_fragment_transform ' ab(  )', '<abbr>ab</abbr>'
	  assert_equal_fragment_transform '<@bạḅdec̣g(  )@>', '<abbr>b<unclear>ab</unclear>de<unclear>c</unclear>g</abbr>'
	  assert_equal_fragment_transform '[ <+(ἡμιωβέλιον)+> <#= 1/2 #> προ(  ) <+(δραχμὴν)+> <#α=1#> <+χ(αλκοῦς 2)+><#=2#>]', '<supplied reason="lost"> <expan><ex>ἡμιωβέλιον</ex></expan> <num value=" 1/2 "/><abbr>προ</abbr> <expan><ex>δραχμὴν</ex></expan> <num value="1">α</num> <expan>χ<ex>αλκοῦς 2</ex></expan><num value="2"/></supplied>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
    def test_abbreviation_uncertain_resolution
      # Ancient abbreviation whose resolution is uncertain
      assert_equal_fragment_transform '<+(abc?)+>', '<expan><ex cert="low">abc</ex></expan>'
	  #assert_equal_fragment_transform '(abc?)', '<expan><ex cert="low">abc</ex></expan>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/lostcertain.html
    def test_lost_dot_gap
      # Some number of missing characters
      assert_equal_fragment_transform '[c.13]', '<gap reason="lost" quantity="c.13" unit="character"/>'
	  assert_equal_fragment_transform '[.1]', '<gap reason="lost" quantity="1" unit="character"/>'
      assert_equal_fragment_transform '[.2]', '<gap reason="lost" quantity="2" unit="character"/>'
      assert_equal_fragment_transform '[.3]', '<gap reason="lost" quantity="3" unit="character"/>'
      (4..100).each do |n|
        assert_equal_fragment_transform "[.#{n}]", "<gap reason=\"lost\" quantity=\"#{n}\" unit=\"character\"/>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/lostcertain.html
    # but extent="unknown" not explicitly combined with unit="character" in guidelines
    def test_lost_gap_unknown
      # Some unknown number of lost characters
      assert_equal_fragment_transform '[.?]', '<gap reason="lost" extent="unknown" unit="character"/>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    def test_illegible_dot_gap
      # Some number of illegible characters not greater than 3
      assert_equal_fragment_transform '.c.13', '<gap reason="illegible" quantity="c.13" unit="character"/>'
	  assert_equal_fragment_transform '.c20', '<gap reason="illegible" quantity="c20" unit="character"/>'
	  assert_equal_fragment_transform '.1', '<gap reason="illegible" quantity="1" unit="character"/>'
      assert_equal_fragment_transform '.2', '<gap reason="illegible" quantity="2" unit="character"/>'
      assert_equal_fragment_transform '.3', '<gap reason="illegible" quantity="3" unit="character"/>'
      (4..100).each do |n|
        assert_equal_fragment_transform ".#{n}", "<gap reason=\"illegible\" quantity=\"#{n}\" unit=\"character\"/>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    def test_illegible_gap_unknown
      # Some unknown number of illegible letters
      assert_equal_fragment_transform '.?', '<gap reason="illegible" extent="unknown" unit="character"/>'
    end
    
    def test_illegible_dot_gap_extentmax
      assert_equal_fragment_transform '.2-3', '<gap reason="illegible" atLeast="2" atMost="3" unit="character"/>'
	  assert_equal_fragment_transform '.7-14', '<gap reason="illegible" atLeast="7" atMost="14" unit="character"/>'
	  assert_equal_fragment_transform '.31-77', '<gap reason="illegible" atLeast="31" atMost="77" unit="character"/>'
    end
	
	def test_lost_dot_gap_extentmax
      # Some number of missing characters
      assert_equal_fragment_transform '[.1-2]', '<gap reason="lost" atLeast="1" atMost="2" unit="character"/>'
      assert_equal_fragment_transform '[.7-14]', '<gap reason="lost" atLeast="7" atMost="14" unit="character"/>'
      assert_equal_fragment_transform '[.31-77]', '<gap reason="lost" atLeast="31" atMost="77" unit="character"/>'
      (11..100).each do |n|
        assert_equal_fragment_transform "[.10-#{n}]", "<gap reason=\"lost\" atLeast=\"10\" atMost=\"#{n}\" unit=\"character\"/>"
      end
    end
  
   def test_illegible_dot_lin
      # Some number of illegible lines
      assert_equal_fragment_transform '.1lin', '<gap reason="illegible" quantity="1" unit="line"/>'
	  assert_equal_fragment_transform '.77lin', '<gap reason="illegible" quantity="77" unit="line"/>'
	  assert_equal_fragment_transform '.100lin', '<gap reason="illegible" quantity="100" unit="line"/>'
    end
	
  def test_illegible_dot_lin_extentmax
      # Some range of illegible lines
      assert_equal_fragment_transform '.1-7lin', '<gap reason="illegible" atLeast="1" atMost="7" unit="line"/>'
	  assert_equal_fragment_transform '.1-27lin', '<gap reason="illegible" atLeast="1" atMost="27" unit="line"/>'
	  assert_equal_fragment_transform '.77-97lin', '<gap reason="illegible" atLeast="77" atMost="97" unit="line"/>'
	  assert_equal_fragment_transform '.87-100lin', '<gap reason="illegible" atLeast="87" atMost="100" unit="line"/>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    # but no desc="vestiges"
    def test_vestige_lines
      # vestiges of N lines, mere smudges really, visible
      assert_equal_fragment_transform 'vestig.3lin', '<gap reason="illegible" quantity="3" unit="line"><desc>vestiges</desc></gap>'
      (1..100).each do |n|
        assert_equal_fragment_transform "vestig.#{n}lin", "<gap reason=\"illegible\" quantity=\"#{n}\" unit=\"line\"><desc>vestiges</desc></gap>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    # but no desc="vestiges"
    def test_vestige_lines_ca
      # vestiges of rough number of lines, mere smudges really, visible
      assert_equal_fragment_transform 'vestig.ca.3lin', '<gap reason="illegible" quantity="3" unit="line" precision="low"><desc>vestiges</desc></gap>'
      (1..100).each do |n|
        assert_equal_fragment_transform "vestig.ca.#{n}lin", "<gap reason=\"illegible\" quantity=\"#{n}\" unit=\"line\" precision=\"low\"><desc>vestiges</desc></gap>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    # should this have desc="vestiges"?
    def test_vestige_lines_unknown
      # vestiges of an unspecified number of lines, mere smudges, visible
      assert_equal_fragment_transform 'vestig.?lin', '<gap reason="illegible" extent="unknown" unit="line"/>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    # but no desc="vestiges"
    def test_vestige_characters
      # vestiges of an unspecified number of characters, mere smudges, visible
      assert_equal_fragment_transform 'vestig', '<gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap>'
    end
  
   #def test_nontran_characters - removed grammar per Jame conversation 6/10
      # non transcripable characters
    #  assert_equal_fragment_transform 'nontran', '<gap desc="non transcr" unit="character"/>'
    #end
  
    # http://www.stoa.org/epidoc/gl/5/lostline.html
    def test_lost_lines
      # Some number of lines is lost
      assert_equal_fragment_transform 'lost.3lin', '<gap reason="lost" quantity="3" unit="line"/>'
      (1..100).each do |n|
        assert_equal_fragment_transform "lost.#{n}lin", "<gap reason=\"lost\" quantity=\"#{n}\" unit=\"line\"/>"
      end
    end
  
    # http://www.stoa.org/epidoc/gl/5/lostline.html
    def test_lost_lines_unknown
      # Some unknown number of lost lines
      assert_equal_fragment_transform 'lost.?lin', '<gap reason="lost" extent="unknown" unit="line"/>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/erroneousomission.html
    def test_omitted
      # Scribe omitted character(s) and modern ed inserted it
      assert_equal_fragment_transform 'a<b>c', 'a<supplied reason="omitted">b</supplied>c'
      assert_equal_fragment_transform '<abc>', '<supplied reason="omitted">abc</supplied>'
	  assert_equal_fragment_transform '<>', '<supplied reason="omitted"/>'
      assert_equal_fragment_transform 'we will <we will> rock you', 'we will <supplied reason="omitted">we will</supplied> rock you'
      assert_equal_fragment_transform 'we ea<t the fi>sh', 'we ea<supplied reason="omitted">t the fi</supplied>sh'
    end
    
    def test_omitted_cert_low
      assert_equal_fragment_transform '<τοῦ?>', '<supplied reason="omitted" cert="low">τοῦ</supplied>'
	  assert_equal_fragment_transform '<ạḅ?>', '<supplied reason="omitted" cert="low"><unclear>ab</unclear></supplied>'
	  assert_equal_fragment_transform '<?>', '<supplied reason="omitted" cert="low"/>'
    end
    
    def test_evidence_parallel
      assert_equal_fragment_transform '_@ς ἐπιστολῆς Θεοδώρου@_', '<supplied evidence="parallel" reason="illegible">ς ἐπιστολῆς Θεοδώρου</supplied>'
	  assert_equal_fragment_transform '_@ωτερίου [τοῦ] λαμπροτά@_', '<supplied evidence="parallel" reason="illegible">ωτερίου <supplied reason="lost">τοῦ</supplied> λαμπροτά</supplied>'
    end
    
    def test_evidence_parallel_cert_low
      assert_equal_fragment_transform '_@ς ἐπιστολῆς Θεοδώρου?@_', '<supplied evidence="parallel" reason="illegible" cert="low">ς ἐπιστολῆς Θεοδώρου</supplied>'
	  assert_equal_fragment_transform '_@ωτερίου [τοῦ] λαμπροτά?@_', '<supplied evidence="parallel" reason="illegible" cert="low">ωτερίου <supplied reason="lost">τοῦ</supplied> λαμπροτά</supplied>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/erroneousinclusion.html
    def test_sic
      # scribe wrote unnecessary characters and modern ed flagged them as such
      assert_equal_fragment_transform '{test}', '<sic>test</sic>'
      assert_equal_fragment_transform 'te{sting 1 2} 3', 'te<sic>sting 1 2</sic> 3'
	  assert_equal_fragment_transform '{.1}', '<sic><gap reason="illegible" quantity="1" unit="character"/></sic>'
	  assert_equal_fragment_transform '{abc.4.2}', '<sic>abc<gap reason="illegible" quantity="4" unit="character"/><gap reason="illegible" quantity="2" unit="character"/></sic>'
	  assert_equal_fragment_transform '{.1ab}', '<sic><gap reason="illegible" quantity="1" unit="character"/>ab</sic>'
	  assert_equal_fragment_transform '{ab.1}', '<sic>ab<gap reason="illegible" quantity="1" unit="character"/></sic>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/supplementforlost.html
    def test_lost
      # modern ed restores lost text
      assert_equal_fragment_transform '[]', '<supplied reason="lost"/>'
	  assert_equal_fragment_transform '[ ?]', '<supplied reason="lost" cert="low"/>'
	  assert_equal_fragment_transform '[abc]', '<supplied reason="lost">abc</supplied>'
	  assert_equal_fragment_transform '[7]', '<supplied reason="lost">7</supplied>'
      assert_equal_fragment_transform 'a[b]c', 'a<supplied reason="lost">b</supplied>c'
      assert_equal_fragment_transform 'a[bc def g]hi', 'a<supplied reason="lost">bc def g</supplied>hi'
    end
  
    # http://www.stoa.org/epidoc/gl/5/supplementforlost.html
    def test_lost_uncertain
      # modern ed restores lost text, with less than total confidence; this proved messy to handle in IDP1
      assert_equal_fragment_transform 'a[bc ?]', 'a<supplied reason="lost" cert="low">bc</supplied>'
  	  assert_equal_fragment_transform '[ạḅ ?]', '<supplied reason="lost" cert="low"><unclear>ab</unclear></supplied>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/unclear.html
    def test_unicode_underdot_unclear
      # eds read dotted letter with less than full confidence
      # TODO: handle existing cert attributes
      # In the current DDB_EpiDoc_XML, only 1809/270095 unclear tags have a cert attribute
      # Those that do all have cert="low"
      assert_equal_fragment_transform 'ạ', '<unclear>a</unclear>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/unclear.html
    def test_unicode_underdot_unclear_combining
      # eds read dotted letter with less than full confidence
      assert_equal_fragment_transform 'ạḅc̣', '<unclear>abc</unclear>'
    end
  
    def test_unicode_underdot_unclear_unspecified
      # eds read dotted letter with less than full confidence
      assert_equal_fragment_transform 'ạḅc̣', '<unclear>abc</unclear>'
    end
  
    # http://www.stoa.org/epidoc/gl/5/unclear.html
    # http://www.stoa.org/epidoc/gl/5/supplementforlost.html
    def test_unicode_underdot_unclear_combining_with_lost
      assert_equal_fragment_transform 'ạḅ[c̣ de]f', '<unclear>ab</unclear><supplied reason="lost"><unclear>c</unclear> de</supplied>f'
    end
  
    # http://www.stoa.org/epidoc/gl/5/deletion.html
    def test_ancient_erasure
      # ancient erasure/cancellation/expunction
      assert_equal_fragment_transform 'a〚bc〛', 'a<del rend="erasure">bc</del>'
      assert_equal_fragment_transform 'ab〚c def g〛hi', 'ab<del rend="erasure">c def g</del>hi'
    end
  
    # no EpiDoc guideline, inherited from TEI
    def test_quotation_marks
      # quotation marks on papyrus
      assert_equal_fragment_transform '"abc"', '<q>abc</q>'
      assert_equal_fragment_transform '"abc def ghi"', '<q>abc def ghi</q>'
	  assert_equal_fragment_transform '"<:ἔλα 3. βα|orth|αιλαβα:> αὐτὰ"', '<q><choice><corr>ἔλα <lb n="3"/>βα</corr><sic>αιλαβα</sic></choice> αὐτὰ</q>'
	   #                                                  '<:a|orth|b:>',     '<choice><corr>a</corr><sic>b</sic></choice>'
    end
  
    def test_uncertain_diacritical_diaeresis
      # Google Doc has U+00AD = soft hyphen before U+00A8 = diaeresis
      # RB notes: I have dropped the soft hyphen
      assert_equal_fragment_transform ' a(¨)bc', '<hi rend="diaeresis">a</hi>bc'
      # test with precombined unicode just to be sure
      assert_equal_fragment_transform ' Ἰ(¨)ουστινιανοῦ', '<hi rend="diaeresis">Ἰ</hi>ουστινιανοῦ'
	  # test with unclears - ex. p.mert.3.125.xml
	  assert_equal_fragment_transform ' ạ(¨)bc', '<hi rend="diaeresis"><unclear>a</unclear></hi>bc'
    end
  
    def test_uncertain_diacritical_grave
      assert_equal_fragment_transform 'abcd e(`)f', 'abcd<hi rend="grave">e</hi>f'
    end
  
    def test_uncertain_diacritical_oxia
      assert_equal_fragment_transform 'abcd e(΄)f', 'abcd<hi rend="oxia">e</hi>f'
    end
  
	def test_uncertain_diacritical_spiritus_asper 
	#can also be known as greek dasia when combined with space per wikipeidia
      assert_equal_fragment_transform ' a( ῾)bc', '<hi rend="asper">a</hi>bc'
    end
        
	def test_uncertain_diacritical_acute
      assert_equal_fragment_transform ' a(´)bc', '<hi rend="acute">a</hi>bc'
    end
        
		def test_uncertain_diacritical_circumflex
      assert_equal_fragment_transform ' a(^)bc', '<hi rend="circumflex">a</hi>bc'
	  assert_equal_fragment_transform ' ạ(^)bc', '<hi rend="circumflex"><unclear>a</unclear></hi>bc'
    end
	
	def test_uncertain_diacritical_spiritus_lenis 
	#can also be known as greek psili when combined with space per wikipeidia
      assert_equal_fragment_transform ' a( ᾿)bc', '<hi rend="lenis">a</hi>bc'
	  assert_equal_fragment_transform ' ạ( ᾿)bc', '<hi rend="lenis"><unclear>a</unclear></hi>bc'
    end
        
    def test_num_simple
      assert_equal_fragment_transform '<#α=1#>', '<num value="1">α</num>'
      assert_equal_fragment_transform '<#α=#>', '<num>α</num>'
	  #below is only num test changed for empty tag processing
      assert_equal_fragment_transform '<#=1#>', '<num value="1"/>'
      assert_equal_fragment_transform '<#δ=1/4#>', '<num value="1/4">δ</num>'
      assert_equal_fragment_transform '<#ιδ=14#>', '<num value="14">ιδ</num>'
	  assert_equal_fragment_transform '<#frac#>', '<num type="fraction"/>'
    end
    
    def test_num_myriads
      assert_equal_fragment_transform '<#μυρίαδες<#β=2#><#Βφ=2500#>=22500#>', '<num value="22500">μυρίαδες<num value="2">β</num><num value="2500">Βφ</num></num>'
    end
    
    def test_choice
      assert_equal_fragment_transform '<:a|orth|b:>', '<choice><corr>a</corr><sic>b</sic></choice>'
	  assert_equal_fragment_transform '<:|orth|b:>', '<choice><corr/><sic>b</sic></choice>'
      assert_equal_fragment_transform '<:a|orth|<:b|orth|c:>:>', '<choice><corr>a</corr><sic><choice><corr>b</corr><sic>c</sic></choice></sic></choice>'
	  assert_equal_fragment_transform '<:a?|orth|b:>', '<choice><corr cert="low">a</corr><sic>b</sic></choice>'
	  assert_equal_fragment_transform '<:a?ạ|orth|bạ:>', '<choice><corr cert="low">a<unclear>a</unclear></corr><sic>b<unclear>a</unclear></sic></choice>'
	end
    
    def test_subst
      assert_equal_fragment_transform '<:a|subst|b:>', '<subst><add place="inline">a</add><del rend="corrected">b</del></subst>'
	  assert_equal_fragment_transform '<:a?|subst|b.1c:>', '<subst><add cert="low" place="inline">a</add><del rend="corrected">b<gap reason="illegible" quantity="1" unit="character"/>c</del></subst>'
    end
    
    def test_app_lem
      assert_equal_fragment_transform '<:a|BL:1.215|b:>', '<app type="BL"><lem resp="1.215">a</lem><rdg>b</rdg></app>'
	  assert_equal_fragment_transform '<:a|BL:|b:>', '<app type="BL"><lem>a</lem><rdg>b</rdg></app>'
      assert_equal_fragment_transform '<:a|ed:bgu 3 p.4|b:>', '<app type="editorial"><lem resp="bgu 3 p.4">a</lem><rdg>b</rdg></app>'
      assert_equal_fragment_transform '<:a|alt:|b:>', '<app type="alternative"><lem>a</lem><rdg>b</rdg></app>'
    end
    
    def test_glyph
	  assert_equal_fragment_transform '*stauros*', '<g type="stauros"/>'
      assert_equal_fragment_transform '*stauros,♱*', '<g type="stauros">♱</g>'
      assert_equal_fragment_transform '*filler(extension)*', '<g rend="extension" type="filler"/>'
	  assert_equal_fragment_transform '*@stauros*', '<orig><g type="stauros"/></orig>'
	  assert_equal_fragment_transform '*mid punctus*', '<g type="mid punctus"/>'
    end
    
    def test_hand_shift
      assert_equal_fragment_transform '$m1 ', '<handShift new="m1"/>'
      assert_equal_fragment_transform '$m20 ', '<handShift new="m20"/>' 
	  assert_equal_fragment_transform '$m1a ', '<handShift new="m1a"/>' 
    end
    
    def test_add_place_supralinear
      assert_equal_fragment_transform '#\ε/#', '<add place="supralinear">ε</add>'
      assert_equal_fragment_transform '#\Πωλίων ἀπάτωρ?/#', '<add place="supralinear" cert="low">Πωλίων ἀπάτωρ</add>'
	  assert_equal_fragment_transform '#\*stauros* τε?/#', '<add place="supralinear" cert="low"><g type="stauros"/> τε</add>'
    end
    
	def test_add_place_intralinear
      assert_equal_fragment_transform '<\ε/>', '<add place="intralinear">ε</add>'
      assert_equal_fragment_transform '<\Πωλίων ἀπάτωρ/>', '<add place="intralinear">Πωλίων ἀπάτωρ</add>'
    end
	
	def test_add_place_infralinear
      assert_equal_fragment_transform '</ε\>', '<add place="infralinear">ε</add>'
      assert_equal_fragment_transform '</Πωλίων ἀπάτωρ\>', '<add place="infralinear">Πωλίων ἀπάτωρ</add>'
    end
	
	def test_add_place_marginal
      assert_equal_fragment_transform '<|ν|>', '<add rend="sling" place="margin">ν</add>'
      assert_equal_fragment_transform '<|.1|>', '<add rend="sling" place="margin"><gap reason="illegible" quantity="1" unit="character"/></add>'
    end
	
    def test_space_unknown
      assert_equal_fragment_transform 'vac.?', '<space extent="unknown" unit="character"/>'
    end
    
    def test_del_rend
      assert_equal_fragment_transform '〚abcdefg〛', '<del rend="erasure">abcdefg</del>'
      assert_equal_fragment_transform '〚Xabcdefg〛', '<del rend="cross-strokes">abcdefg</del>'
      assert_equal_fragment_transform '〚/abcdefg〛', '<del rend="slashes">abcdefg</del>'
    end
    
    def test_note
      assert_equal_fragment_transform '/*abcdefg*/', '<note place="not specified" xml:lang="en">abcdefg</note>'
	  assert_equal_fragment_transform '/*?*/', '<note place="not specified" xml:lang="en">?</note>'
	  assert_equal_fragment_transform '/*m2?*/', '<note place="not specified" xml:lang="en">m2?</note>'
	  assert_equal_fragment_transform '/*text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4*/', '<note place="not specified" xml:lang="en">text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4</note>'
    end
    
    def test_foreign_lang
      assert_equal_fragment_transform '~veni vedi vici~la ', '<foreign xml:lang="la">veni vedi vici</foreign>'
    end
    
    def test_milestone
      assert_equal_fragment_transform '----', '<milestone rend="paragraphos" unit="undefined"/>'
      assert_equal_fragment_transform '--------', '<milestone rend="horizontal-rule" unit="undefined"/>'
	  assert_equal_fragment_transform '###', '<milestone rend="box" unit="undefined"/>'
    end
    
    def test_figure
      ['seal', 'stamp', 'drawing'].each do |figdesc|
        assert_equal_fragment_transform "\##{figdesc} ", "<figure><figDesc>#{figdesc}</figDesc></figure>"
      end
    end
    
    def test_simple_reversibility
      assert_equal_non_xml_to_xml_to_non_xml "<=1. test=>", "<=1. test=>"
      assert_equal_non_xml_to_xml_to_non_xml "<=1. test1\n2. test2=>", "<=1. test1\n2. test2=>"
    end
  
    def test_multiple_ab
      #test multiple ab sections
	  assert_equal_fragment_transform '{.1ab}=><=12. {ab.1}', '<sic><gap reason="illegible" quantity="1" unit="character"/>ab</sic></ab><ab><lb n="12"/><sic>ab<gap reason="illegible" quantity="1" unit="character"/></sic>'
    end
	
	def test_line_number_formats
      assert_equal_non_xml_to_xml_to_non_xml "<=1. test=>", "<=1. test=>"
      assert_equal_non_xml_to_xml_to_non_xml "<=1a. test1a=>", "<=1a. test1a=>"
	  assert_equal_non_xml_to_xml_to_non_xml "<=4/5. test45=>", "<=4/5. test45=>"
	  assert_equal_non_xml_to_xml_to_non_xml "<=14/15. test1415=>", "<=14/15. test1415=>"
	  assert_equal_non_xml_to_xml_to_non_xml "<=1,ms. test1ms=>", "<=1,ms. test1ms=>"
	  assert_equal_non_xml_to_xml_to_non_xml "<=17,ms. test17ms=>", "<=17,ms. test17ms=>"
    end
	
  
    def test_line_numbering_reversibility_exhaustive
      #(1..100).each do |num_lines|
        str = ''
        #(1..num_lines).each do |this_line|
		(1..100).each do |this_line|
          str += "#{this_line}. test#{this_line}\n"
        end
        str.chomp!
		# I think the line below doing Leiden+ wrapper will have to moved/rethougt if the the outter loop is reactivated
		str = "<=" + str + "=>"
        assert_equal_non_xml_to_xml_to_non_xml str, str
      #end
    end
  
    def test_xml_trailing_newline_stripped
	# added \n at end to prove newline not stripped anymore
      assert_equal_non_xml_to_xml_to_non_xml "<=1. test\n=>", "<=1. test\n=>"
      assert_equal_non_xml_to_xml_to_non_xml "<=1. test1\n2. test2\n=>", "<=1. test1\n2. test2\n=>"
    end
  
    def test_unicode_greek_reversibility
      assert_equal_non_xml_to_xml_to_non_xml '<=1. ςερτυθιοπασδφγηξκλζχψωβνμ=>', '<=1. ςερτυθιοπασδφγηξκλζχψωβνμ=>'
    end
  
    def test_xsugar_reversibility_true
      assert @xsugar.reversible?
    end
  end
end