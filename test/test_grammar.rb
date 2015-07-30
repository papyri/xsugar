if(RUBY_PLATFORM == 'java')
  require File.join(File.dirname(__FILE__), 'test_helper')

  class GrammarTest < Test::Unit::TestCase
    # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
    
  def test_place_generic
    assert_equal_fragment_transform '||bottom:ς ἐπιστολῆς Θεοδώρου||', '<add place="bottom">ς ἐπιστολῆς Θεοδώρου</add>'
    assert_equal_fragment_transform '||bottom:ς ἐπιστολῆς Θεοδώρου(?)||', '<add place="bottom">ς ἐπιστολῆς Θεοδώρου<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '||top:ς ἐπιστολῆς Θεοδώρου||', '<add place="top">ς ἐπιστολῆς Θεοδώρου</add>'
    assert_equal_fragment_transform '||left:ς ἐπιστολῆς Θεοδώρου||', '<add place="left">ς ἐπιστολῆς Θεοδώρου</add>'
    assert_equal_fragment_transform '||margin:ς ἐπιστολῆς Θεοδώρου||', '<add place="margin">ς ἐπιστολῆς Θεοδώρου</add>'
    assert_equal_fragment_transform '||margin:ς ἐπιστολῆς Θεοδώρου(?)||', '<add place="margin">ς ἐπιστολῆς Θεοδώρου<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '||right:ς ἐπιστολῆς Θεοδώρου||', '<add place="right">ς ἐπιστολῆς Θεοδώρου</add>'
    assert_equal_fragment_transform '||margin:ς ἐπ̣ιστολῆς Θ[εοδ]ώρου||', '<add place="margin">ς ἐ<unclear>π</unclear>ιστολῆς Θ<supplied reason="lost">εοδ</supplied>ώρου</add>'
    assert_equal_fragment_transform '||bottom:ς ἐπ̣ιστολῆς Θ[εοδ]ώρου||', '<add place="bottom">ς ἐ<unclear>π</unclear>ιστολῆς Θ<supplied reason="lost">εοδ</supplied>ώρου</add>'
    assert_equal_fragment_transform '||margin:ς ἐπ̣ιστολῆς Θ[εοδ]ώρου(?)||', '<add place="margin">ς ἐ<unclear>π</unclear>ιστολῆς Θ<supplied reason="lost">εοδ</supplied>ώρου<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '||bottom:ς ἐπ̣ιστολῆς Θ[εοδ]ώρου(?)||', '<add place="bottom">ς ἐ<unclear>π</unclear>ιστολῆς Θ<supplied reason="lost">εοδ</supplied>ώρου<certainty match=".." locus="name"/></add>'
  end
  
  def test_expansion
      # Ancient abbreviation whose resolution is known
      assert_equal_fragment_transform '(a(b))', '<expan>a<ex>b</ex></expan>'
  end
    
  def test_expansion_multiple
    assert_equal_fragment_transform '(ab(c)def(gh)i(j))', '<expan>ab<ex>c</ex>def<ex>gh</ex>i<ex>j</ex></expan>'
  end
    
  def test_expansion_with_supp
    assert_equal_fragment_transform 'abc[def] ([gh]i(jk))', 'abc<supplied reason="lost">def</supplied> <expan><supplied reason="lost">gh</supplied>i<ex>jk</ex></expan>'
    assert_equal_fragment_transform '(a[b(cd)])', '<expan>a<supplied reason="lost">b<ex>cd</ex></supplied></expan>'
    assert_equal_fragment_transform '([(eton)])', '<expan><supplied reason="lost"><ex>eton</ex></supplied></expan>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
  def test_symbol_expansion
    # Single symbol for an entire word
    assert_equal_fragment_transform '((abc))', '<expan><ex>abc</ex></expan>'
    assert_equal_fragment_transform '((ἑπτα)κωμίας)', '<expan><ex>ἑπτα</ex>κωμίας</expan>'
    assert_equal_fragment_transform '((ἑπτα)κω̣μίας)', '<expan><ex>ἑπτα</ex>κ<unclear>ω</unclear>μίας</expan>'
    assert_equal_fragment_transform '((ἑπτα)κω̣μ[ία̣]ς)', '<expan><ex>ἑπτα</ex>κ<unclear>ω</unclear>μ<supplied reason="lost">ί<unclear>α</unclear></supplied>ς</expan>'
  end
  
  def test_expan_redo_pretty_exhaustive
    assert_equal_fragment_transform '(πωμαρ[(ί)]υ̣)', '<expan>πωμαρ<supplied reason="lost"><ex>ί</ex></supplied><unclear>υ</unclear></expan>'
    assert_equal_fragment_transform '(ἀ[κρ̣ό̣δ̣(ρυα)])', '<expan>ἀ<supplied reason="lost">κ<unclear>ρόδ</unclear><ex>ρυα</ex></supplied></expan>'
    assert_equal_fragment_transform '(ἀ[κ ρ̣ό̣δ̣(ρυα)])', '<expan>ἀ<supplied reason="lost">κ <unclear>ρόδ</unclear><ex>ρυα</ex></supplied></expan>'
    assert_equal_fragment_transform '([(Ἑπτα)]κ̣ω̣μ̣[(ίας)])', '<expan><supplied reason="lost"><ex>Ἑπτα</ex></supplied><unclear>κωμ</unclear><supplied reason="lost"><ex>ίας</ex></supplied></expan>'
    assert_equal_fragment_transform '([Κ(α)ρ]ανίδ(ος))', '<expan><supplied reason="lost">Κ<ex>α</ex>ρ</supplied>ανίδ<ex>ος</ex></expan>'
    assert_equal_fragment_transform '((῾επταρούρῳ))', '<expan><ex>῾επταρούρῳ</ex></expan>'
    assert_equal_fragment_transform '((ἀρταβίας᾿?))', '<expan><ex cert="low">ἀρταβίας᾿</ex></expan>'
    assert_equal_fragment_transform '<:(Ἀ ι(¨)ου[λ(ίου)]) [.?] =BL 8.455|ed|(Ἰου[λ(ίου)]) [.?] :>', '<app type="editorial"><lem resp="BL 8.455"><expan>Ἀ<hi rend="diaeresis">ι</hi>ου<supplied reason="lost">λ<ex>ίου</ex></supplied></expan> <gap reason="lost" extent="unknown" unit="character"/> </lem><rdg><expan>Ἰου<supplied reason="lost">λ<ex>ίου</ex></supplied></expan> <gap reason="lost" extent="unknown" unit="character"/> </rdg></app>'
    assert_equal_fragment_transform '(Ψ̣α ΐ(¨)ο(υ))', '<expan><unclear>Ψ</unclear>α<hi rend="diaeresis">ΐ</hi>ο<ex>υ</ex></expan>'
    assert_equal_fragment_transform '(Ψεvac.?ν(τ))', '<expan>Ψε<space extent="unknown" unit="character"/>ν<ex>τ</ex></expan>'
    assert_equal_fragment_transform '(μο̣ύ ι(¨)(α))', '<expan>μ<unclear>ο</unclear>ύ<hi rend="diaeresis">ι</hi><ex>α</ex></expan>'
    assert_equal_fragment_transform '(Ψ̣α ί(¨)ο(υ))', '<expan><unclear>Ψ</unclear>α<hi rend="diaeresis">ί</hi>ο<ex>υ</ex></expan>'
    assert_equal_fragment_transform '(ἔ̣πα ι(¨)(τον))', '<expan><unclear>ἔ</unclear>πα<hi rend="diaeresis">ι</hi><ex>τον</ex></expan>'
    assert_equal_fragment_transform '(Θεμα ΐ(¨)τ[ο(ς)(?)])', '<expan>Θεμα<hi rend="diaeresis">ΐ</hi>τ<supplied reason="lost" cert="low">ο<ex>ς</ex></supplied></expan>'
    assert_equal_fragment_transform '(Α[.2]ωνο(ς))', '<expan>Α<gap reason="lost" quantity="2" unit="character"/>ωνο<ex>ς</ex></expan>'
    assert_equal_fragment_transform '([.?].1λινο̣κ(αλάμης))', '<expan><gap reason="lost" extent="unknown" unit="character"/><gap reason="illegible" quantity="1" unit="character"/>λιν<unclear>ο</unclear>κ<ex>αλάμης</ex></expan>'
    assert_equal_fragment_transform '([.?]ή̣σιο(ς))', '<expan><gap reason="lost" extent="unknown" unit="character"/><unclear>ή</unclear>σιο<ex>ς</ex></expan>'
    assert_equal_fragment_transform '([.?]ωνο(ς))', '<expan><gap reason="lost" extent="unknown" unit="character"/>ωνο<ex>ς</ex></expan>'
    assert_equal_fragment_transform '([.?]ε̣ί̣δ(ης?))', '<expan><gap reason="lost" extent="unknown" unit="character"/><unclear>εί</unclear>δ<ex cert="low">ης</ex></expan>'
    assert_equal_fragment_transform '([.?].1ω(νος))', '<expan><gap reason="lost" extent="unknown" unit="character"/><gap reason="illegible" quantity="1" unit="character"/>ω<ex>νος</ex></expan>'
    assert_equal_fragment_transform '([.?](ἀρουρ ))', '<expan><gap reason="lost" extent="unknown" unit="character"/><ex>ἀρουρ </ex></expan>'
    assert_equal_fragment_transform '(ab[cdef(ghi)(?)])', '<expan>ab<supplied reason="lost" cert="low">cdef<ex>ghi</ex></supplied></expan>'
    assert_equal_fragment_transform '(ab[cdef(ghi?)])', '<expan>ab<supplied reason="lost">cdef<ex cert="low">ghi</ex></supplied></expan>'
    assert_equal_fragment_transform '(ab[cdef(ghi)])', '<expan>ab<supplied reason="lost">cdef<ex>ghi</ex></supplied></expan>'
    assert_equal_fragment_transform '(κ̣(ατ)οί̣[κ(ων)(?)])', '<expan><unclear>κ</unclear><ex>ατ</ex>ο<unclear>ί</unclear><supplied reason="lost" cert="low">κ<ex>ων</ex></supplied></expan>'
    assert_equal_fragment_transform '(κ̣(ατ))', '<expan><unclear>κ</unclear><ex>ατ</ex></expan>'
    assert_equal_fragment_transform '(κ̣(ατ)(ατ))', '<expan><unclear>κ</unclear><ex>ατ</ex><ex>ατ</ex></expan>'
    assert_equal_fragment_transform '(κ̣(ατ)ο)', '<expan><unclear>κ</unclear><ex>ατ</ex>ο</expan>'
    assert_equal_fragment_transform '(κ̣(ατ)οί̣)', '<expan><unclear>κ</unclear><ex>ατ</ex>ο<unclear>ί</unclear></expan>'
    assert_equal_fragment_transform '(κ̣(ατ)οί̣[(ων)])', '<expan><unclear>κ</unclear><ex>ατ</ex>ο<unclear>ί</unclear><supplied reason="lost"><ex>ων</ex></supplied></expan>'
    assert_equal_fragment_transform '(κ̣(ατ)οί̣[κ(ων)])', '<expan><unclear>κ</unclear><ex>ατ</ex>ο<unclear>ί</unclear><supplied reason="lost">κ<ex>ων</ex></supplied></expan>'
    #below here from short run
    assert_equal_fragment_transform '((abc))', '<expan><ex>abc</ex></expan>'
    assert_equal_fragment_transform '[ίως ((ἔτους)) <#ι=10(?)#>  καὶ ]', '<supplied reason="lost">ίως <expan><ex>ἔτους</ex></expan> <num value="10">ι<certainty match="../@value" locus="value"/></num>  καὶ </supplied>'
    assert_equal_fragment_transform '([(eton)])', '<expan><supplied reason="lost"><ex>eton</ex></supplied></expan>'
    assert_equal_fragment_transform '(ab(c)def(gh)i(j))', '<expan>ab<ex>c</ex>def<ex>gh</ex>i<ex>j</ex></expan>'
    assert_equal_fragment_transform '_[(ἀρ(τάβας?)) (δωδέκ(ατον)) (εἰκ(οστοτέταρτον?)) ((ἀρτάβας)) <#ιβ \'=1/12#> <#κδ \'=1/24#> *stauros* <:Ἀγαθάμμων=BL 8.441|ed|(δ(ι)) (|μ|) κάμμονι:> \*stauros*/ *tachygraphic-marks*(?)]_', '<supplied evidence="parallel" reason="lost" cert="low"><expan>ἀρ<ex cert="low">τάβας</ex></expan> <expan>δωδέκ<ex>ατον</ex></expan> <expan>εἰκ<ex cert="low">οστοτέταρτον</ex></expan> <expan><ex>ἀρτάβας</ex></expan> <num value="1/12" rend="tick">ιβ</num> <num value="1/24" rend="tick">κδ</num> <g type="stauros"/> <app type="editorial"><lem resp="BL 8.441">Ἀγαθάμμων</lem><rdg><expan>δ<ex>ι</ex></expan> <abbr>μ</abbr> κάμμονι</rdg></app> <add place="above"><g type="stauros"/></add> <g type="tachygraphic-marks"/></supplied>'
    assert_equal_fragment_transform '((abc 123))', '<expan><ex>abc 123</ex></expan>'
    assert_equal_fragment_transform '[ ((ἡμιωβέλιον)) <#=1/2#>(|προ|) ((δραχμὴν)) <#α=1#> (χ(αλκοῦς 2))<#=2#>]', '<supplied reason="lost"> <expan><ex>ἡμιωβέλιον</ex></expan> <num value="1/2"/><abbr>προ</abbr> <expan><ex>δραχμὴν</ex></expan> <num value="1">α</num> <expan>χ<ex>αλκοῦς 2</ex></expan><num value="2"/></supplied>'
    assert_equal_fragment_transform '<:[.?]<#λβ=32#> .2 ἐκ <((ταλάντων))> <#κζ=27#> <((δραχμῶν))> <#Γ=3000#> ((τάλαντα)) <#ωοθ=879#> <((δραχμαὶ))> <#Γσ=3200#>=SoSOL Sosin|ed|[.?]<#λβ=32#> <#𐅵 \'=1/2#> <#ιβ \'=1/12#> ἐκ ((ταλάντων)) <#ζ=7#> <#Γ=3000#> ((τάλαντα)) <#ωοθ=879#> <#η \'=1/8(?)#>:>', '<app type="editorial"><lem resp="SoSOL Sosin"><gap reason="lost" extent="unknown" unit="character"/><num value="32">λβ</num> <gap reason="illegible" quantity="2" unit="character"/> ἐκ <supplied reason="omitted"><expan><ex>ταλάντων</ex></expan></supplied> <num value="27">κζ</num> <supplied reason="omitted"><expan><ex>δραχμῶν</ex></expan></supplied> <num value="3000">Γ</num> <expan><ex>τάλαντα</ex></expan> <num value="879">ωοθ</num> <supplied reason="omitted"><expan><ex>δραχμαὶ</ex></expan></supplied> <num value="3200">Γσ</num></lem><rdg><gap reason="lost" extent="unknown" unit="character"/><num value="32">λβ</num> <num value="1/2" rend="tick">𐅵</num> <num value="1/12" rend="tick">ιβ</num> ἐκ <expan><ex>ταλάντων</ex></expan> <num value="7">ζ</num> <num value="3000">Γ</num> <expan><ex>τάλαντα</ex></expan> <num value="879">ωοθ</num> <num value="1/8" rend="tick">η<certainty match="../@value" locus="value"/></num></rdg></app>'
    assert_equal_fragment_transform '<:(|πριμο̣σκ|)|alt|(|πριμσκ|):>', '<app type="alternative"><lem><abbr>πριμ<unclear>ο</unclear>σκ</abbr></lem><rdg><abbr>πριμσκ</abbr></rdg></app>'
    assert_equal_fragment_transform '<:(|πριμο̣σκ|)|alt|(|πριμσκ(?)|):>', '<app type="alternative"><lem><abbr>πριμ<unclear>ο</unclear>σκ</abbr></lem><rdg><abbr>πριμσκ<certainty locus="name" match=".."/></abbr></rdg></app>'
    assert_equal_fragment_transform '((ἑπτα)κωμίας)', '<expan><ex>ἑπτα</ex>κωμίας</expan>'
    assert_equal_fragment_transform '((ἑπτα)κω̣μίας)', '<expan><ex>ἑπτα</ex>κ<unclear>ω</unclear>μίας</expan>'
    assert_equal_fragment_transform '((ἑπτα)κω̣μ[ία̣]ς)', '<expan><ex>ἑπτα</ex>κ<unclear>ω</unclear>μ<supplied reason="lost">ί<unclear>α</unclear></supplied>ς</expan>'
    assert_equal_fragment_transform '(ἀρ[γ(υρικῶν?)])', '<expan>ἀρ<supplied reason="lost">γ<ex cert="low">υρικῶν</ex></supplied></expan>'
    assert_equal_fragment_transform '((ἑκατονταρ)χ(ίας))', '<expan><ex>ἑκατονταρ</ex>χ<ex>ίας</ex></expan>'
    assert_equal_fragment_transform '(τετ[ελ(ευτηκότος?)])', '<expan>τετ<supplied reason="lost">ελ<ex cert="low">ευτηκότος</ex></supplied></expan>'
    assert_equal_fragment_transform '((ἑκατοντάρ)χ(ῳ))', '<expan><ex>ἑκατοντάρ</ex>χ<ex>ῳ</ex></expan>'
    assert_equal_fragment_transform '((ἑκατοντάρ)χ(ῃ))', '<expan><ex>ἑκατοντάρ</ex>χ<ex>ῃ</ex></expan>'
    assert_equal_fragment_transform '((ἑκατοντά)ρχ(ῳ))', '<expan><ex>ἑκατοντά</ex>ρχ<ex>ῳ</ex></expan>'
    assert_equal_fragment_transform '((ἑκατοντά)ρχ(ῳ))', '<expan><ex>ἑκατοντά</ex>ρχ<ex>ῳ</ex></expan>'
    assert_equal_fragment_transform '(ἀριθ(μητικοῦ))', '<expan>ἀριθ<ex>μητικοῦ</ex></expan>'
    assert_equal_fragment_transform '([κ(ατ)]οί(κων))', '<expan><supplied reason="lost">κ<ex>ατ</ex></supplied>οί<ex>κων</ex></expan>'
    assert_equal_fragment_transform '([κ]οι(νῆσ))', '<expan><supplied reason="lost">κ</supplied>οι<ex>νῆσ</ex></expan>'
    assert_equal_fragment_transform '(ἐν[τ(έτακται?)])', '<expan>ἐν<supplied reason="lost">τ<ex cert="low">έτακται</ex></supplied></expan>'
    assert_equal_fragment_transform '([δ]ι(ὰ))', '<expan><supplied reason="lost">δ</supplied>ι<ex>ὰ</ex></expan>'
    assert_equal_fragment_transform '(κ̣ώ̣(μησ))', '<expan><unclear>κώ</unclear><ex>μησ</ex></expan>'
    assert_equal_fragment_transform '((ἑκατοντάρ)χ(ῃ))', '<expan><ex>ἑκατοντάρ</ex>χ<ex>ῃ</ex></expan>'
    assert_equal_fragment_transform '(χ(ιλιά)ρ(χῃ))', '<expan>χ<ex>ιλιά</ex>ρ<ex>χῃ</ex></expan>'
    #supplied cert low
    assert_equal_fragment_transform '(ab[cdef(ghi)(?)])', '<expan>ab<supplied reason="lost" cert="low">cdef<ex>ghi</ex></supplied></expan>'
    assert_equal_fragment_transform '(ab[cdef(ghi?)])', '<expan>ab<supplied reason="lost">cdef<ex cert="low">ghi</ex></supplied></expan>'
    assert_equal_fragment_transform '(ab[cdef(ghi)])', '<expan>ab<supplied reason="lost">cdef<ex>ghi</ex></supplied></expan>'
    assert_equal_fragment_transform '(κ̣(ατ)οί̣[κ(ων)(?)])', '<expan><unclear>κ</unclear><ex>ατ</ex>ο<unclear>ί</unclear><supplied reason="lost" cert="low">κ<ex>ων</ex></supplied></expan>'
    # supplied lost starting with markup
    assert_equal_fragment_transform '(ἀ[κ ρ̣ό̣δ̣(ρυα)])', '<expan>ἀ<supplied reason="lost">κ <unclear>ρόδ</unclear><ex>ρυα</ex></supplied></expan>'
    assert_equal_fragment_transform '(γί̣[κ ρ̣ό̣δ̣(ρυα)])', '<expan>γ<unclear>ί</unclear><supplied reason="lost">κ <unclear>ρόδ</unclear><ex>ρυα</ex></supplied></expan>'
    assert_equal_fragment_transform '(γί̣[ον̣(νται)])', '<expan>γ<unclear>ί</unclear><supplied reason="lost">ο<unclear>ν</unclear><ex>νται</ex></supplied></expan>'
    assert_equal_fragment_transform '(γί̣[ν ο(νται)])', '<expan>γ<unclear>ί</unclear><supplied reason="lost">ν ο<ex>νται</ex></supplied></expan>'
    assert_equal_fragment_transform '(γί̣[aν̣ο(νται)])', '<expan>γ<unclear>ί</unclear><supplied reason="lost">a<unclear>ν</unclear>ο<ex>νται</ex></supplied></expan>'
    assert_equal_fragment_transform '(γί̣[ν̣ο(νται)])', '<expan>γ<unclear>ί</unclear><supplied reason="lost"><unclear>ν</unclear>ο<ex>νται</ex></supplied></expan>'
    # supplied evidence
    assert_equal_fragment_transform '(Αὐρ|_(ηλίας)_|)', '<expan>Αὐρ<supplied evidence="parallel" reason="undefined"><ex>ηλίας</ex></supplied></expan>'
    assert_equal_fragment_transform '(ἀπη[λ]|_(ιώτου)_|)', '<expan>ἀπη<supplied reason="lost">λ</supplied><supplied evidence="parallel" reason="undefined"><ex>ιώτου</ex></supplied></expan>'
    assert_equal_fragment_transform '(Θεμα ΐ(¨)τ|_ο(ς)_|)', '<expan>Θεμα<hi rend="diaeresis">ΐ</hi>τ<supplied evidence="parallel" reason="undefined">ο<ex>ς</ex></supplied></expan>'
    assert_equal_fragment_transform '(ab|_cdef(ghi)_|)', '<expan>ab<supplied evidence="parallel" reason="undefined">cdef<ex>ghi</ex></supplied></expan>'
    assert_equal_fragment_transform '(κ̣(ατ)οί̣|_κ(ων)_|)', '<expan><unclear>κ</unclear><ex>ατ</ex>ο<unclear>ί</unclear><supplied evidence="parallel" reason="undefined">κ<ex>ων</ex></supplied></expan>'
    assert_equal_fragment_transform '(ab|_cdef(ghi)_|)', '<expan>ab<supplied evidence="parallel" reason="undefined">cdef<ex>ghi</ex></supplied></expan>'
    assert_equal_fragment_transform '(κ̣(ατ)οί̣|_κ(ων)_|)', '<expan><unclear>κ</unclear><ex>ατ</ex>ο<unclear>ί</unclear><supplied evidence="parallel" reason="undefined">κ<ex>ων</ex></supplied></expan>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
  # http://www.stoa.org/epidoc/gl/5/numbersandnumerals.html
  # possibly: http://www.stoa.org/epidoc/gl/5/acrophonic.html
  def test_counting_symbol_expansion
    assert_equal_fragment_transform '((abc 123))', '<expan><ex>abc 123</ex></expan>'

  end
  
  # http://www.stoa.org/epidoc/gl/5/abbreviationsnotunderstood.html
  def test_abbreviation_unknown_resolution
    # Ancient abbreviation whose resolution is unknown
    assert_equal_fragment_transform '(|ab|)', '<abbr>ab</abbr>'
    assert_equal_fragment_transform '(|bạḅdec̣g|)', '<abbr>b<unclear>ab</unclear>de<unclear>c</unclear>g</abbr>'
    assert_equal_fragment_transform '(|bạḅdec̣g(?)|)', '<abbr>b<unclear>ab</unclear>de<unclear>c</unclear>g<certainty locus="name" match=".."/></abbr>'
    assert_equal_fragment_transform '[ ((ἡμιωβέλιον)) <#=1/2#>(|προ|) ((δραχμὴν)) <#α=1#> (χ(αλκοῦς 2))<#=2#>]', '<supplied reason="lost"> <expan><ex>ἡμιωβέλιον</ex></expan> <num value="1/2"/><abbr>προ</abbr> <expan><ex>δραχμὴν</ex></expan> <num value="1">α</num> <expan>χ<ex>αλκοῦς 2</ex></expan><num value="2"/></supplied>'
    assert_equal_fragment_transform '(|υιω(?)|)', '<abbr>υιω<certainty locus="name" match=".."/></abbr>'
    assert_equal_fragment_transform '<:(|πριμο̣σκ|)|alt|(|πριμσκ|):>', '<app type="alternative"><lem><abbr>πριμ<unclear>ο</unclear>σκ</abbr></lem><rdg><abbr>πριμσκ</abbr></rdg></app>'
    assert_equal_fragment_transform '<:(|πριμο̣σκ|)|alt|(|πριμσκ(?)|):>', '<app type="alternative"><lem><abbr>πριμ<unclear>ο</unclear>σκ</abbr></lem><rdg><abbr>πριμσκ<certainty locus="name" match=".."/></abbr></rdg></app>'
    assert_equal_fragment_transform '<:.5(( ))|alt|(|κουδ(?)|) :>', '<app type="alternative"><lem><gap reason="illegible" quantity="5" unit="character"/><expan><ex> </ex></expan></lem><rdg><abbr>κουδ<certainty locus="name" match=".."/></abbr> </rdg></app>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/abbreviationsunderstood.html
  def test_abbreviation_uncertain_resolution
    # Ancient abbreviation whose resolution is uncertain
    assert_equal_fragment_transform '((abc?))', '<expan><ex cert="low">abc</ex></expan>'
  end
  
  def test_gap_certainty_match
    assert_equal_fragment_transform '[.3(?)]', '<gap reason="lost" quantity="3" unit="character"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '.3(?) ', '<gap reason="illegible" quantity="3" unit="character"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform 'lost.3lin(?) ', '<gap reason="lost" quantity="3" unit="line"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '.3lin(?) ', '<gap reason="illegible" quantity="3" unit="line"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '[.?(?)]', '<gap reason="lost" extent="unknown" unit="character"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '.?(?) ', '<gap reason="illegible" extent="unknown" unit="character"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform 'lost.?lin(?) ', '<gap reason="lost" extent="unknown" unit="line"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform 'vestig.?lin(?) ', '<gap reason="illegible" extent="unknown" unit="line"><certainty match=".." locus="name"/></gap>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/lostcertain.html
  def test_lost_dot_gap
    # Some number of missing characters
    assert_equal_fragment_transform '[ca.13]', '<gap reason="lost" quantity="13" unit="character" precision="low"/>'
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
    assert_equal_fragment_transform 'ca.13', '<gap reason="illegible" quantity="13" unit="character" precision="low"/>'
    assert_equal_fragment_transform 'ca.20', '<gap reason="illegible" quantity="20" unit="character" precision="low"/>'
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
    assert_equal_fragment_transform '.3-5(?) ', '<gap reason="illegible" atLeast="3" atMost="5" unit="character"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '.3-5lin', '<gap reason="illegible" atLeast="3" atMost="5" unit="line"/>'
    assert_equal_fragment_transform '.3-5lin(?) ', '<gap reason="illegible" atLeast="3" atMost="5" unit="line"><certainty match=".." locus="name"/></gap>'
  end
  
  def test_lost_dot_gap_extentmax
    # Some number of missing characters
    assert_equal_fragment_transform '[.1-2]', '<gap reason="lost" atLeast="1" atMost="2" unit="character"/>'
    assert_equal_fragment_transform '[.3-5(?)]', '<gap reason="lost" atLeast="3" atMost="5" unit="character"><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform 'lost.3-5lin', '<gap reason="lost" atLeast="3" atMost="5" unit="line"/>'
    assert_equal_fragment_transform 'lost.3-5lin(?) ', '<gap reason="lost" atLeast="3" atMost="5" unit="line"><certainty match=".." locus="name"/></gap>'
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
    assert_equal_fragment_transform 'ca.7lin', '<gap reason="illegible" quantity="7" unit="line" precision="low"/>'
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
    assert_equal_fragment_transform 'vestig.ca.7lin', '<gap reason="illegible" quantity="7" unit="line" precision="low"><desc>vestiges</desc></gap>'
    assert_equal_fragment_transform 'vestig.3lin', '<gap reason="illegible" quantity="3" unit="line"><desc>vestiges</desc></gap>'
    (1..100).each do |n|
      assert_equal_fragment_transform "vestig.#{n}lin", "<gap reason=\"illegible\" quantity=\"#{n}\" unit=\"line\"><desc>vestiges</desc></gap>"
    end
  end
  
  # http://www.stoa.org/epidoc/gl/5/vestiges.html
  # but no desc="vestiges"
  def test_vestige_lines_ca
    # vestiges of rough number of lines, mere smudges really, visible
    assert_equal_fragment_transform 'vestig.ca.7lin', '<gap reason="illegible" quantity="7" unit="line" precision="low"><desc>vestiges</desc></gap>'
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
    assert_equal_fragment_transform 'vestig ', '<gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap>'
    assert_equal_fragment_transform 'vestig.7char', '<gap reason="illegible" quantity="7" unit="character"><desc>vestiges</desc></gap>'
    assert_equal_fragment_transform 'vestig.ca.7char', '<gap reason="illegible" quantity="7" unit="character" precision="low"><desc>vestiges</desc></gap>'
  end

  # http://www.stoa.org/epidoc/gl/5/lostline.html
  def test_lost_lines
    # Some number of lines is lost
    assert_equal_fragment_transform 'lost.ca.7lin', '<gap reason="lost" quantity="7" unit="line" precision="low"/>'
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
    assert_equal_fragment_transform 'we will <we will> rock you', 'we will <supplied reason="omitted">we will</supplied> rock you'
    assert_equal_fragment_transform 'we ea<t the fi>sh', 'we ea<supplied reason="omitted">t the fi</supplied>sh'
    assert_equal_fragment_transform '<.?>', '<gap reason="omitted" extent="unknown" unit="character"/>'
    assert_equal_fragment_transform '<.12>', '<gap reason="omitted" quantity="12" unit="character"/>'
  end
    
  def test_omitted_cert_low
    assert_equal_fragment_transform '<τοῦ(?)>', '<supplied reason="omitted" cert="low">τοῦ</supplied>'
    assert_equal_fragment_transform '<ạḅ(?)>', '<supplied reason="omitted" cert="low"><unclear>ab</unclear></supplied>'
  end
    
  def test_evidence_parallel
    assert_equal_fragment_transform '|_ς ἐπιστολῆς Θεοδώρου_|', '<supplied evidence="parallel" reason="undefined">ς ἐπιστολῆς Θεοδώρου</supplied>'
    assert_equal_fragment_transform '|_ωτερίου [τοῦ] λαμπροτά_|', '<supplied evidence="parallel" reason="undefined">ωτερίου <supplied reason="lost">τοῦ</supplied> λαμπροτά</supplied>'
    assert_equal_fragment_transform '[|_.3ς_|]', '<supplied reason="lost"><supplied evidence="parallel" reason="undefined"><gap reason="illegible" quantity="3" unit="character"/>ς</supplied></supplied>'
    assert_equal_fragment_transform '[|_ἐν̣_|]', '<supplied reason="lost"><supplied evidence="parallel" reason="undefined">ἐ<unclear>ν</unclear></supplied></supplied>'
    assert_equal_fragment_transform '[εστῶτος μ|_η̣ν̣ὸ̣ς̣_|]', '<supplied reason="lost">εστῶτος μ<supplied evidence="parallel" reason="undefined"><unclear>ηνὸς</unclear></supplied></supplied>'
    assert_equal_fragment_transform '|_ρῳ Φ[ιλά]_|', '<supplied evidence="parallel" reason="undefined">ρῳ Φ<supplied reason="lost">ιλά</supplied></supplied>'
    assert_equal_fragment_transform '_[Πόσεις]_', '<supplied evidence="parallel" reason="lost">Πόσεις</supplied>'
    assert_equal_fragment_transform '_[ρῳ Φ[ιλά]]_', '<supplied evidence="parallel" reason="lost">ρῳ Φ<supplied reason="lost">ιλά</supplied></supplied>'
  end
  
  def test_evidence_parallel_cert_low
    assert_equal_fragment_transform '|_ς ἐπιστολῆς Θεοδώρου(?)_|', '<supplied evidence="parallel" reason="undefined" cert="low">ς ἐπιστολῆς Θεοδώρου</supplied>'
    assert_equal_fragment_transform '|_ωτερίου [τοῦ] λαμπροτά(?)_|', '<supplied evidence="parallel" reason="undefined" cert="low">ωτερίου <supplied reason="lost">τοῦ</supplied> λαμπροτά</supplied>'
    assert_equal_fragment_transform '|_ρῳ Φ[ιλά](?)_|', '<supplied evidence="parallel" reason="undefined" cert="low">ρῳ Φ<supplied reason="lost">ιλά</supplied></supplied>'
    assert_equal_fragment_transform '_[Πόσεις(?)]_', '<supplied evidence="parallel" reason="lost" cert="low">Πόσεις</supplied>'
    assert_equal_fragment_transform '_[(ἀρ(τάβας?)) (δωδέκ(ατον)) (εἰκ(οστοτέταρτον?)) ((ἀρτάβας)) <#ιβ \'=1/12#> <#κδ \'=1/24#> *stauros* <:Ἀγαθάμμων=BL 8.441|ed|(δ(ι)) (|μ|) κάμμονι:> \*stauros*/ *tachygraphic-marks*(?)]_', '<supplied evidence="parallel" reason="lost" cert="low"><expan>ἀρ<ex cert="low">τάβας</ex></expan> <expan>δωδέκ<ex>ατον</ex></expan> <expan>εἰκ<ex cert="low">οστοτέταρτον</ex></expan> <expan><ex>ἀρτάβας</ex></expan> <num value="1/12" rend="tick">ιβ</num> <num value="1/24" rend="tick">κδ</num> <g type="stauros"/> <app type="editorial"><lem resp="BL 8.441">Ἀγαθάμμων</lem><rdg><expan>δ<ex>ι</ex></expan> <abbr>μ</abbr> κάμμονι</rdg></app> <add place="above"><g type="stauros"/></add> <g type="tachygraphic-marks"/></supplied>'
    #rendtick assert_equal_fragment_transform '_[(ἀρ(τάβας?)) (δωδέκ(ατον)) (εἰκ(οστοτέταρτον?)) ((ἀρτάβας)) <#ιβ=frac1/12#> <#κδ=frac1/24#> *stauros* <:Ἀγαθάμμων=BL 8.441|ed|(δ(ι)) (|μ|) κάμμονι:> \*stauros*/ *tachygraphic-marks*(?)]_', '<supplied evidence="parallel" reason="lost" cert="low"><expan>ἀρ<ex cert="low">τάβας</ex></expan> <expan>δωδέκ<ex>ατον</ex></expan> <expan>εἰκ<ex cert="low">οστοτέταρτον</ex></expan> <expan><ex>ἀρτάβας</ex></expan> <num value="1/12" rend="fraction">ιβ</num> <num value="1/24" rend="fraction">κδ</num> <g type="stauros"/> <app type="editorial"><lem resp="BL 8.441">Ἀγαθάμμων</lem><rdg><expan>δ<ex>ι</ex></expan> <abbr>μ</abbr> κάμμονι</rdg></app> <add place="above"><g type="stauros"/></add> <g type="tachygraphic-marks"/></supplied>'
  end
  
    # http://www.stoa.org/epidoc/gl/5/erroneousinclusion.html
  def test_surplus
    # scribe wrote unnecessary characters and modern ed flagged them as such
    assert_equal_fragment_transform '{test}', '<surplus>test</surplus>'
    assert_equal_fragment_transform 'te{sting 1 2} 3', 'te<surplus>sting 1 2</surplus> 3'
    assert_equal_fragment_transform '{.1}', '<surplus><gap reason="illegible" quantity="1" unit="character"/></surplus>'
    assert_equal_fragment_transform '{abc.4.2}', '<surplus>abc<gap reason="illegible" quantity="4" unit="character"/><gap reason="illegible" quantity="2" unit="character"/></surplus>'
    assert_equal_fragment_transform '{.1ab}', '<surplus><gap reason="illegible" quantity="1" unit="character"/>ab</surplus>'
    assert_equal_fragment_transform '{ab.1}', '<surplus>ab<gap reason="illegible" quantity="1" unit="character"/></surplus>'
    assert_equal_fragment_transform '{π̣αρ(?)}', '<surplus><unclear>π</unclear>αρ<certainty match=".." locus="value"/></surplus>'
    assert_equal_fragment_transform '{εἰς(?)}', '<surplus>εἰς<certainty match=".." locus="value"/></surplus>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/supplementforlost.html
  def test_lost
    # modern ed restores lost text
    assert_equal_fragment_transform '[καὶ(?)]', '<supplied reason="lost" cert="low">καὶ</supplied>'
    assert_equal_fragment_transform '[παρὰ]', '<supplied reason="lost">παρὰ</supplied>'
    assert_equal_fragment_transform 'a[b]c', 'a<supplied reason="lost">b</supplied>c'
    assert_equal_fragment_transform 'a[bc def g]hi', 'a<supplied reason="lost">bc def g</supplied>hi'
  end
  
  # http://www.stoa.org/epidoc/gl/5/supplementforlost.html
  def test_lost_uncertain
    # modern ed restores lost text, with less than total confidence; this proved messy to handle in IDP1
    assert_equal_fragment_transform 'a[bc(?)]', 'a<supplied reason="lost" cert="low">bc</supplied>'
    assert_equal_fragment_transform '[ạḅ(?)]', '<supplied reason="lost" cert="low"><unclear>ab</unclear></supplied>'
    assert_equal_fragment_transform 'a[bc]', 'a<supplied reason="lost">bc</supplied>'
    assert_equal_fragment_transform '[ạḅ]', '<supplied reason="lost"><unclear>ab</unclear></supplied>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/unclear.html
  def test_unicode_underdot_unclear
    # eds read dotted letter with less than full confidence
    assert_equal_fragment_transform 'ạ', '<unclear>a</unclear>'
    assert_equal_fragment_transform 'ε̣ͅ', '<unclear>εͅ</unclear>'
    assert_equal_fragment_transform 'ε̣͂', '<unclear>ε͂</unclear>'
  end
  
  # http://www.stoa.org/epidoc/gl/5/unclear.html
  def test_unicode_underdot_unclear_combining
    # eds read dotted letter with less than full confidence
    assert_equal_fragment_transform 'ạḅc̣', '<unclear>abc</unclear>'
    assert_equal_fragment_transform 'ạε̣͂c̣', '<unclear>aε͂c</unclear>'
    assert_equal_fragment_transform 'ạε̣͂c̣ε̣͂', '<unclear>aε͂cε͂</unclear>'
    assert_equal_fragment_transform 'ε̣͂ε̣͂ε̣͂', '<unclear>ε͂ε͂ε͂</unclear>'
    assert_equal_fragment_transform 'ε̣͂ḅε̣͂', '<unclear>ε͂bε͂</unclear>'
    assert_equal_fragment_transform 'ε̣͂ḅε̣͂ḅ', '<unclear>ε͂bε͂b</unclear>'
    assert_equal_fragment_transform '1. πάρες εͅε͂ ε̣͂ḅε̣͂ḅ add', '<lb n="1"/>πάρες εͅε͂ <unclear>ε͂bε͂b</unclear> add'
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
    assert_equal_fragment_transform '"<:ἔλα 3. βα|corr|αιλαβα:> αὐτὰ"', '<q><choice><corr>ἔλα <lb n="3"/>βα</corr><sic>αιλαβα</sic></choice> αὐτὰ</q>'
    assert_equal_fragment_transform '[Ἁρχῦψις] "¯[Πετεή]¯σιος" αγδ  "δεξβεφξβν" ςεφξνςφη', '<supplied reason="lost">Ἁρχῦψις</supplied> <q><hi rend="supraline"><supplied reason="lost">Πετεή</supplied></hi>σιος</q> αγδ  <q>δεξβεφξβν</q> ςεφξνςφη'
  end
  
  def test_uncertain_diacritical_diaeresis
    assert_equal_fragment_transform ' a(¨)bc', '<hi rend="diaeresis">a</hi>bc'
    assert_equal_fragment_transform ' a(¨)(?)bc', '<hi rend="diaeresis">a<certainty match=".." locus="value"/></hi>bc'
    # test with precombined unicode just to be sure
    assert_equal_fragment_transform ' Ἰ(¨)ουστινιανοῦ', '<hi rend="diaeresis">Ἰ</hi>ουστινιανοῦ'
    assert_equal_fragment_transform ' Ἰ(¨)(?)ουστινιανοῦ', '<hi rend="diaeresis">Ἰ<certainty match=".." locus="value"/></hi>ουστινιανοῦ'
    # test with unclears - ex. p.mert.3.125.xml
    assert_equal_fragment_transform ' ạ(¨)bc', '<hi rend="diaeresis"><unclear>a</unclear></hi>bc'
    assert_equal_fragment_transform ' ạ(¨)(?)bc', '<hi rend="diaeresis"><unclear>a</unclear><certainty match=".." locus="value"/></hi>bc'
    assert_equal_fragment_transform ' [.1](¨)', '<hi rend="diaeresis"><gap reason="lost" quantity="1" unit="character"/></hi>'
    assert_equal_fragment_transform ' .1(¨)', '<hi rend="diaeresis"><gap reason="illegible" quantity="1" unit="character"/></hi>'
  end
  
  def test_uncertain_diacritical_grave
    assert_equal_fragment_transform 'abcd e(`)f', 'abcd<hi rend="grave">e</hi>f'
    assert_equal_fragment_transform ' [.1](`)', '<hi rend="grave"><gap reason="lost" quantity="1" unit="character"/></hi>'
    assert_equal_fragment_transform ' .1(`)', '<hi rend="grave"><gap reason="illegible" quantity="1" unit="character"/></hi>'
    assert_equal_fragment_transform ' ἃ̣(`)', '<hi rend="grave"><unclear>ἃ</unclear></hi>'
  end
  
  def test_uncertain_diacritical_spiritus_asper 
    #can also be known as greek dasia when combined with space per wikipeidia
    assert_equal_fragment_transform ' a( ῾)bc', '<hi rend="asper">a</hi>bc'
  end
        
  def test_uncertain_diacritical_acute
    assert_equal_fragment_transform ' a(´)bc', '<hi rend="acute">a</hi>bc'
    assert_equal_fragment_transform ' ο(´ ῾)', '<hi rend="acute"><hi rend="asper">ο</hi></hi>'
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
  
  def test_num_exhaustive
    assert_equal_fragment_transform '<#=14#>', '<num value="14"/>'
    assert_equal_fragment_transform '<#=1/4#>', '<num value="1/4"/>'
    assert_equal_fragment_transform '<#α=#>', '<num>α</num>'
    
    assert_equal_fragment_transform '<#α=frac#>', '<num type="fraction">α</num>'
    assert_equal_fragment_transform '<#ο \'=frac#>', '<num type="fraction" rend="tick">ο</num>'
    assert_equal_fragment_transform '<#ο \'=15#>', '<num value="15" rend="tick">ο</num>'
    assert_equal_fragment_transform '<#ο \'=1/5#>', '<num value="1/5" rend="tick">ο</num>'
    assert_equal_fragment_transform '<#ο \'=15(?)#>', '<num value="15" rend="tick">ο<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#ο \'=1/5(?)#>', '<num value="1/5" rend="tick">ο<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#ο=15#>', '<num value="15">ο</num>'
    assert_equal_fragment_transform '<#ο=1/5#>', '<num value="1/5">ο</num>'
    assert_equal_fragment_transform '<#ο=15(?)#>', '<num value="15">ο<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#ο=1/5(?)#>', '<num value="1/5">ο<certainty match="../@value" locus="value"/></num>'
    #myriads below
    assert_equal_fragment_transform '<#.1=frac#>', '<num type="fraction"><gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1ο=frac#>', '<num type="fraction"><gap reason="illegible" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#ι.1=frac#>', '<num type="fraction">ι<gap reason="illegible" quantity="1" unit="character"/></num>'
    
    assert_equal_fragment_transform '<#.1 \'=frac#>', '<num type="fraction" rend="tick"><gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1ο \'=frac#>', '<num type="fraction" rend="tick"><gap reason="illegible" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#ι.1 \'=frac#>', '<num type="fraction" rend="tick">ι<gap reason="illegible" quantity="1" unit="character"/></num>'
    
    assert_equal_fragment_transform '<#.1 \'=16#>', '<num value="16" rend="tick"><gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1ο \'=16#>', '<num value="16" rend="tick"><gap reason="illegible" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#ι.1 \'=16#>', '<num value="16" rend="tick">ι<gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1 \'=16(?)#>', '<num value="16" rend="tick"><gap reason="illegible" quantity="1" unit="character"/><certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#.1ο \'=16(?)#>', '<num value="16" rend="tick"><gap reason="illegible" quantity="1" unit="character"/>ο<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#ι.1 \'=16(?)#>', '<num value="16" rend="tick">ι<gap reason="illegible" quantity="1" unit="character"/><certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#.1 \'=1/6#>', '<num value="1/6" rend="tick"><gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1ο \'=1/6#>', '<num value="1/6" rend="tick"><gap reason="illegible" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#ι.1 \'=1/6#>', '<num value="1/6" rend="tick">ι<gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1 \'=1/6(?)#>', '<num value="1/6" rend="tick"><gap reason="illegible" quantity="1" unit="character"/><certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#.1ο \'=1/6(?)#>', '<num value="1/6" rend="tick"><gap reason="illegible" quantity="1" unit="character"/>ο<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#ι.1 \'=1/6(?)#>', '<num value="1/6" rend="tick">ι<gap reason="illegible" quantity="1" unit="character"/><certainty match="../@value" locus="value"/></num>'
    
    assert_equal_fragment_transform '<#.1=16#>', '<num value="16"><gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1ο=16#>', '<num value="16"><gap reason="illegible" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#ι.1=16#>', '<num value="16">ι<gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1=16(?)#>', '<num value="16"><gap reason="illegible" quantity="1" unit="character"/><certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#.1ο=16(?)#>', '<num value="16"><gap reason="illegible" quantity="1" unit="character"/>ο<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#ι.1=16(?)#>', '<num value="16">ι<gap reason="illegible" quantity="1" unit="character"/><certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#.1=1/6#>', '<num value="1/6"><gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1ο=1/6#>', '<num value="1/6"><gap reason="illegible" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#ι.1=1/6#>', '<num value="1/6">ι<gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1=1/6(?)#>', '<num value="1/6"><gap reason="illegible" quantity="1" unit="character"/><certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#.1ο=1/6(?)#>', '<num value="1/6"><gap reason="illegible" quantity="1" unit="character"/>ο<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#ι.1=1/6(?)#>', '<num value="1/6">ι<gap reason="illegible" quantity="1" unit="character"/><certainty match="../@value" locus="value"/></num>'
    
    assert_equal_fragment_transform '<#ο \'=#>', '<num rend="tick">ο</num>'
    assert_equal_fragment_transform '<#.1 \'=#>', '<num rend="tick"><gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1ο \'=#>', '<num rend="tick"><gap reason="illegible" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#ι.1 \'=#>', '<num rend="tick">ι<gap reason="illegible" quantity="1" unit="character"/></num>'
    
    assert_equal_fragment_transform '<#.1=#>', '<num><gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#.1ο=#>', '<num><gap reason="illegible" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#ι.1=#>', '<num>ι<gap reason="illegible" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#α=#>', '<num>α</num>'
    #range below
    
    assert_equal_fragment_transform '<#[.1] \'=frac#>', '<num type="fraction" rend="tick"><gap reason="lost" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#[.1]ο \'=frac#>', '<num type="fraction" rend="tick"><gap reason="lost" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#.2 \'=frac#>', '<num type="fraction" rend="tick"><gap reason="illegible" quantity="2" unit="character"/></num>'
    
    assert_equal_fragment_transform '<#[.1]=frac#>', '<num type="fraction"><gap reason="lost" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#[.1]ο=frac#>', '<num type="fraction"><gap reason="lost" quantity="1" unit="character"/>ο</num>'
    assert_equal_fragment_transform '<#.2=frac#>', '<num type="fraction"><gap reason="illegible" quantity="2" unit="character"/></num>'
    
    ###orig below
    assert_equal_fragment_transform '<#α=1#>', '<num value="1">α</num>'
    assert_equal_fragment_transform '<#α=#>', '<num>α</num>'
  #below is only num test changed for empty tag processing
    assert_equal_fragment_transform '<#=1#>', '<num value="1"/>'
    assert_equal_fragment_transform '<#δ=1/4#>', '<num value="1/4">δ</num>'
    assert_equal_fragment_transform '<#ιδ=14#>', '<num value="14">ιδ</num>'
    assert_equal_fragment_transform '<#Α=1000(?)#>', '<num value="1000">Α<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '<#[ι]γ=13(?)#>', '<num value="13"><supplied reason="lost">ι</supplied>γ<certainty match="../@value" locus="value"/></num>'
    assert_equal_fragment_transform '[ίως ((ἔτους)) <#ι=10(?)#>  καὶ ]', '<supplied reason="lost">ίως <expan><ex>ἔτους</ex></expan> <num value="10">ι<certainty match="../@value" locus="value"/></num>  καὶ </supplied>'
    assert_equal_fragment_transform '<#a=1-9#>', '<num atLeast="1" atMost="9">a</num>'
    assert_equal_fragment_transform '<#κ[.1]=20-29#>', '<num atLeast="20" atMost="29">κ<gap reason="lost" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#ι̣=10-19#>', '<num atLeast="10" atMost="19"><unclear>ι</unclear></num>'
    assert_equal_fragment_transform '<#a=1-?#>', '<num atLeast="1">a</num>'
    assert_equal_fragment_transform '<#κ[.1]=20-?#>', '<num atLeast="20">κ<gap reason="lost" quantity="1" unit="character"/></num>'
    assert_equal_fragment_transform '<#ι̣=10-?#>', '<num atLeast="10"><unclear>ι</unclear></num>'
  end
  
  def test_num_myriads
    assert_equal_fragment_transform '<#μυρίαδες<#β=2#><#Βφ=2500#>=22500#>', '<num value="22500">μυρίαδες<num value="2">β</num><num value="2500">Βφ</num></num>'
  end
  
  def test_choice
    assert_equal_fragment_transform '<:a|corr|b:>', '<choice><corr>a</corr><sic>b</sic></choice>'
    assert_equal_fragment_transform '<:a|corr|<:b|corr|c:>:>', '<choice><corr>a</corr><sic><choice><corr>b</corr><sic>c</sic></choice></sic></choice>'
    assert_equal_fragment_transform '<:a(?)|corr|b:>', '<choice><corr cert="low">a</corr><sic>b</sic></choice>'
    assert_equal_fragment_transform '<:aạ(?)|corr|bạ:>', '<choice><corr cert="low">a<unclear>a</unclear></corr><sic>b<unclear>a</unclear></sic></choice>'
    assert_equal_fragment_transform '<:σωλῆνας̣(?)|corr|σηληνας̣:>', '<choice><corr cert="low">σωλῆνα<unclear>ς</unclear></corr><sic>σηληνα<unclear>ς</unclear></sic></choice>'
    assert_equal_fragment_transform '<:σωλῆνας̣|corr|σηληνας̣(?):>', '<choice><corr>σωλῆνα<unclear>ς</unclear></corr><sic>σηληνα<unclear>ς</unclear><certainty match=".." locus="value"/></sic></choice>'
    assert_equal_fragment_transform '<:σωλῆνας̣(?)|corr|σηληνας̣(?):>', '<choice><corr cert="low">σωλῆνα<unclear>ς</unclear></corr><sic>σηληνα<unclear>ς</unclear><certainty match=".." locus="value"/></sic></choice>'
    assert_equal_fragment_transform '<:σωλῆνας̣|corr|σηληνας̣:>', '<choice><corr>σωλῆνα<unclear>ς</unclear></corr><sic>σηληνα<unclear>ς</unclear></sic></choice>'
    assert_equal_fragment_transform '<:a(?)|corr|<:b|corr|c:>:>', '<choice><corr cert="low">a</corr><sic><choice><corr>b</corr><sic>c</sic></choice></sic></choice>'
    assert_equal_fragment_transform '<:a|corr|<:b|corr|c(?):>:>', '<choice><corr>a</corr><sic><choice><corr>b</corr><sic>c<certainty match=".." locus="value"/></sic></choice></sic></choice>'
    assert_equal_fragment_transform '<:<:b|corr|c:>|corr|σηλη:>', '<choice><corr><choice><corr>b</corr><sic>c</sic></choice></corr><sic>σηλη</sic></choice>'
    #new reg stuff
    assert_equal_fragment_transform '<:a|reg|b:>', '<choice><reg>a</reg><orig>b</orig></choice>'
    assert_equal_fragment_transform '<:a|reg|<:b|reg|c:>:>', '<choice><reg>a</reg><orig><choice><reg>b</reg><orig>c</orig></choice></orig></choice>'
    assert_equal_fragment_transform '<:a(?)|reg|b:>', '<choice><reg cert="low">a</reg><orig>b</orig></choice>'
    assert_equal_fragment_transform '<:aạ(?)|reg|bạ:>', '<choice><reg cert="low">a<unclear>a</unclear></reg><orig>b<unclear>a</unclear></orig></choice>'
    assert_equal_fragment_transform '<:σωλῆνας̣(?)|reg|σηληνας̣:>', '<choice><reg cert="low">σωλῆνα<unclear>ς</unclear></reg><orig>σηληνα<unclear>ς</unclear></orig></choice>'
    assert_equal_fragment_transform '<:σωλῆνας̣|reg|σηληνας̣(?):>', '<choice><reg>σωλῆνα<unclear>ς</unclear></reg><orig>σηληνα<unclear>ς</unclear><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:σωλῆνας̣(?)|reg|σηληνας̣(?):>', '<choice><reg cert="low">σωλῆνα<unclear>ς</unclear></reg><orig>σηληνα<unclear>ς</unclear><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:σωλῆνας̣|reg|σηληνας̣:>', '<choice><reg>σωλῆνα<unclear>ς</unclear></reg><orig>σηληνα<unclear>ς</unclear></orig></choice>'
    assert_equal_fragment_transform '<:a(?)|reg|<:b|reg|c:>:>', '<choice><reg cert="low">a</reg><orig><choice><reg>b</reg><orig>c</orig></choice></orig></choice>'
    assert_equal_fragment_transform '<:a|reg|<:b|reg|c(?):>:>', '<choice><reg>a</reg><orig><choice><reg>b</reg><orig>c<certainty match=".." locus="value"/></orig></choice></orig></choice>'
    assert_equal_fragment_transform '<:<:b|reg|c:>|reg|σηλη:>', '<choice><reg><choice><reg>b</reg><orig>c</orig></choice></reg><orig>σηλη</orig></choice>'
    #combined
    assert_equal_fragment_transform '<:a|corr|<:b|reg|c:>:>', '<choice><corr>a</corr><sic><choice><reg>b</reg><orig>c</orig></choice></sic></choice>'
    assert_equal_fragment_transform '<:<:b|corr|c:>|reg|σηλη:>', '<choice><reg><choice><corr>b</corr><sic>c</sic></choice></reg><orig>σηλη</orig></choice>'
    assert_equal_fragment_transform '<:a|reg|<:b|corr|c:>:>', '<choice><reg>a</reg><orig><choice><corr>b</corr><sic>c</sic></choice></orig></choice>'
    assert_equal_fragment_transform '<:<:b|reg|c:>|corr|σηλη:>', '<choice><corr><choice><reg>b</reg><orig>c</orig></choice></corr><sic>σηλη</sic></choice>'
  end
    
  def test_mult_regs_no_nattrib_with_tall
    assert_equal_fragment_transform '<:James~||Jaymes||~tallJomes|reg|Jeames:>', '<choice><reg>James<hi rend="tall">Jaymes</hi>Jomes</reg><orig>Jeames</orig></choice>'
    assert_equal_fragment_transform '<:Jon|Jean|Jun|John||reg||Jan:>', '<choice><reg>Jon</reg><reg>Jean</reg><reg>Jun</reg><reg>John</reg><orig>Jan</orig></choice>'
  end
    
  def test_mult_regs_no_nattrib
    assert_equal_fragment_transform '<:Jon=grc|Jean=ital|Jun=de|John(?)=en||reg||Jan:>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="ital">Jean</reg><reg xml:lang="de">Jun</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John(?)=en||reg||Jan:>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John=en||reg||Jan:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg xml:lang="en">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John(?)=en||reg||Jan:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John=en||reg||Jan:>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="en">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon|John(?)||reg||Jan:>', '<choice><reg>Jon</reg><reg cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John||reg||Jan:>', '<choice><reg cert="low">Jon</reg><reg>John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John(?)||reg||Jan:>', '<choice><reg cert="low">Jon</reg><reg cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon|John||reg||Jan:>', '<choice><reg>Jon</reg><reg>John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon|John=en||reg||Jan:>', '<choice><reg>Jon</reg><reg xml:lang="en">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John||reg||Jan:>', '<choice><reg xml:lang="grc">Jon</reg><reg>John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John=en||reg||Jan:>', '<choice><reg cert="low">Jon</reg><reg xml:lang="en">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John(?)=en||reg||Jan:>', '<choice><reg cert="low">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon|John(?)=en||reg||Jan:>', '<choice><reg>Jon</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John||reg||Jan:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg>John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John(?)||reg||Jan:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John(?)||reg||Jan:>', '<choice><reg xml:lang="grc">Jon</reg><reg cert="low">John</reg><orig>Jan</orig></choice>'
  end
    
  def test_mult_regs_with_markup_origcert_no_nattrib
      #all above tests with orig with certainty
    assert_equal_fragment_transform '<:Jon=grc|Jean=ital|Jun=de|John(?)=en||reg||Jan(?):>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="ital">Jean</reg><reg xml:lang="de">Jun</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John(?)=en||reg||Jan(?):>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John=en||reg||Jan(?):>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg xml:lang="en">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John(?)=en||reg||Jan(?):>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John=en||reg||Jan(?):>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="en">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon|John(?)||reg||Jan(?):>', '<choice><reg>Jon</reg><reg cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John||reg||Jan(?):>', '<choice><reg cert="low">Jon</reg><reg>John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John(?)||reg||Jan(?):>', '<choice><reg cert="low">Jon</reg><reg cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon|John||reg||Jan(?):>', '<choice><reg>Jon</reg><reg>John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon|John=en||reg||Jan(?):>', '<choice><reg>Jon</reg><reg xml:lang="en">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John||reg||Jan(?):>', '<choice><reg xml:lang="grc">Jon</reg><reg>John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John=en||reg||Jan(?):>', '<choice><reg cert="low">Jon</reg><reg xml:lang="en">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John(?)=en||reg||Jan(?):>', '<choice><reg cert="low">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon|John(?)=en||reg||Jan(?):>', '<choice><reg>Jon</reg><reg xml:lang="en" cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John||reg||Jan(?):>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg>John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John(?)||reg||Jan(?):>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John(?)||reg||Jan(?):>', '<choice><reg xml:lang="grc">Jon</reg><reg cert="low">John</reg><orig>Jan<certainty match=".." locus="value"/></orig></choice>'
  end
  
  def test_mult_regs_with_markup_no_nattrib
    #all above tests with orig being markup
    assert_equal_fragment_transform '<:Jon=grc|Jean=ital|Jun=de|John(?)=en||reg||[Jan]:>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="ital">Jean</reg><reg xml:lang="de">Jun</reg><reg xml:lang="en" cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John(?)=en||reg||[Jan]:>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John=en||reg||[Jan]:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg xml:lang="en">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John(?)=en||reg||[Jan]:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John=en||reg||[Jan]:>', '<choice><reg xml:lang="grc">Jon</reg><reg xml:lang="en">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon|John(?)||reg||[Jan]:>', '<choice><reg>Jon</reg><reg cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John||reg||[Jan]:>', '<choice><reg cert="low">Jon</reg><reg>John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John(?)||reg||[Jan]:>', '<choice><reg cert="low">Jon</reg><reg cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon|John||reg||[Jan]:>', '<choice><reg>Jon</reg><reg>John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon|John=en||reg||[Jan]:>', '<choice><reg>Jon</reg><reg xml:lang="en">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John||reg||[Jan]:>', '<choice><reg xml:lang="grc">Jon</reg><reg>John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John=en||reg||[Jan]:>', '<choice><reg cert="low">Jon</reg><reg xml:lang="en">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|John(?)=en||reg||[Jan]:>', '<choice><reg cert="low">Jon</reg><reg xml:lang="en" cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon|John(?)=en||reg||[Jan]:>', '<choice><reg>Jon</reg><reg xml:lang="en" cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John||reg||[Jan]:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg>John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|John(?)||reg||[Jan]:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|John(?)||reg||[Jan]:>', '<choice><reg xml:lang="grc">Jon</reg><reg cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
  end
  
  def test_mult_regs_nested_etc_no_nattrib
    #break reg and origs with markup combinations
    assert_equal_fragment_transform '<:[Jon](?)=grc|[John](?)=en||reg||[Jan]:>', '<choice><reg xml:lang="grc" cert="low"><supplied reason="lost">Jon</supplied></reg><reg xml:lang="en" cert="low"><supplied reason="lost">John</supplied></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[Jon]=grc|[John]=en||reg||[Jan]:>', '<choice><reg xml:lang="grc"><supplied reason="lost">Jon</supplied></reg><reg xml:lang="en"><supplied reason="lost">John</supplied></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[Jon](?)|[John](?)||reg||[Jan]:>', '<choice><reg cert="low"><supplied reason="lost">Jon</supplied></reg><reg cert="low"><supplied reason="lost">John</supplied></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[Jon]|[John]||reg||[Jan]:>', '<choice><reg><supplied reason="lost">Jon</supplied></reg><reg><supplied reason="lost">John</supplied></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[.3]=grc|John(?)=en||reg||Jan:>', '<choice><reg xml:lang="grc"><gap reason="lost" quantity="3" unit="character"/></reg><reg xml:lang="en" cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|[.4]=en||reg||Jan:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg xml:lang="en"><gap reason="lost" quantity="4" unit="character"/></reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:[.3](?)=grc|John(?)=en||reg||Jan:>', '<choice><reg xml:lang="grc" cert="low"><gap reason="lost" quantity="3" unit="character"/></reg><reg xml:lang="en" cert="low">John</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon|[.4](?)||reg||Jan:>', '<choice><reg>Jon</reg><reg cert="low"><gap reason="lost" quantity="4" unit="character"/></reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:[.3]=grc|John(?)=en||reg||[Jan]:>', '<choice><reg xml:lang="grc"><gap reason="lost" quantity="3" unit="character"/></reg><reg xml:lang="en" cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|[.4]=en||reg||[Jan]:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><reg xml:lang="en"><gap reason="lost" quantity="4" unit="character"/></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[.3](?)=grc|John(?)=en||reg||[Jan]:>', '<choice><reg xml:lang="grc" cert="low"><gap reason="lost" quantity="3" unit="character"/></reg><reg xml:lang="en" cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon|[.4](?)||reg||[Jan]:>', '<choice><reg>Jon</reg><reg cert="low"><gap reason="lost" quantity="4" unit="character"/></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:June=BL 1.123|ed|<:Jon|John||reg||Jan:>:>', '<app type="editorial"><lem resp="BL 1.123">June</lem><rdg><choice><reg>Jon</reg><reg>John</reg><orig>Jan</orig></choice></rdg></app>'
    assert_equal_fragment_transform '<:June=BL 1.123|ed|<:[.3](?)=grc|John(?)=en||reg||[Jan]:>:>', '<app type="editorial"><lem resp="BL 1.123">June</lem><rdg><choice><reg xml:lang="grc" cert="low"><gap reason="lost" quantity="3" unit="character"/></reg><reg xml:lang="en" cert="low">John</reg><orig><supplied reason="lost">Jan</supplied></orig></choice></rdg></app>'
    #Josh adds
    assert_equal_fragment_transform '<:June=BL 1.123|ed|<:Jon|John(?)||reg||<:Jön|subst|jan:>:>:>', '<app type="editorial"><lem resp="BL 1.123">June</lem><rdg><choice><reg>Jon</reg><reg cert="low">John</reg><orig><subst><add place="inline">Jön</add><del rend="corrected">jan</del></subst></orig></choice></rdg></app>'
    assert_equal_fragment_transform '<:<:Jun[e]|subst|jan:>=BL 1.123|ed|<:Jon|John(?)||reg||<:Jön|subst|jan:>:>:>', '<app type="editorial"><lem resp="BL 1.123"><subst><add place="inline">Jun<supplied reason="lost">e</supplied></add><del rend="corrected">jan</del></subst></lem><rdg><choice><reg>Jon</reg><reg cert="low">John</reg><orig><subst><add place="inline">Jön</add><del rend="corrected">jan</del></subst></orig></choice></rdg></app>'
    assert_equal_fragment_transform '<:(Jen(nifer))=BL 4.567|ed|<:<:Jun[e]|subst|jan:>=BL 1.123|ed|<:Jon|John(?)||reg||<:Jön|subst|jan:>:>:>:>', '<app type="editorial"><lem resp="BL 4.567"><expan>Jen<ex>nifer</ex></expan></lem><rdg><app type="editorial"><lem resp="BL 1.123"><subst><add place="inline">Jun<supplied reason="lost">e</supplied></add><del rend="corrected">jan</del></subst></lem><rdg><choice><reg>Jon</reg><reg cert="low">John</reg><orig><subst><add place="inline">Jön</add><del rend="corrected">jan</del></subst></orig></choice></rdg></app></rdg></app>'
    assert_equal_fragment_transform '<:<:(Jen(nifer))|corr|(Ren(nifer)):>=BL 4.567|ed|<:<:Jun[e]|subst|jan:>=BL 1.123|ed|<:Jon|John(?)||reg||<:Jön|subst|jan:>:>:>:>', '<app type="editorial"><lem resp="BL 4.567"><choice><corr><expan>Jen<ex>nifer</ex></expan></corr><sic><expan>Ren<ex>nifer</ex></expan></sic></choice></lem><rdg><app type="editorial"><lem resp="BL 1.123"><subst><add place="inline">Jun<supplied reason="lost">e</supplied></add><del rend="corrected">jan</del></subst></lem><rdg><choice><reg>Jon</reg><reg cert="low">John</reg><orig><subst><add place="inline">Jön</add><del rend="corrected">jan</del></subst></orig></choice></rdg></app></rdg></app>'
  end
  
  def test_reg_with_lang
    assert_equal_fragment_transform '<:Jon(?)=grc|reg|Jan:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|reg|[Jan](?):>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><orig><supplied reason="lost">Jan</supplied><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)=grc|reg|[Jan]:>', '<choice><reg xml:lang="grc" cert="low">Jon</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[Jon](?)=grc|reg|Jan:>', '<choice><reg xml:lang="grc" cert="low"><supplied reason="lost">Jon</supplied></reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:[Jon](?)=grc|reg|[Jan](?):>', '<choice><reg xml:lang="grc" cert="low"><supplied reason="lost">Jon</supplied></reg><orig><supplied reason="lost">Jan</supplied><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:[Jon](?)=grc|reg|[Jan]:>', '<choice><reg xml:lang="grc" cert="low"><supplied reason="lost">Jon</supplied></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|reg|Jan:>', '<choice><reg xml:lang="grc">Jon</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|reg|[Jan](?):>', '<choice><reg xml:lang="grc">Jon</reg><orig><supplied reason="lost">Jan</supplied><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon=grc|reg|[Jan]:>', '<choice><reg xml:lang="grc">Jon</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[Jon]=grc|reg|Jan:>', '<choice><reg xml:lang="grc"><supplied reason="lost">Jon</supplied></reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:[Jon]=grc|reg|[Jan](?):>', '<choice><reg xml:lang="grc"><supplied reason="lost">Jon</supplied></reg><orig><supplied reason="lost">Jan</supplied><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:[Jon]=grc|reg|[Jan]:>', '<choice><reg xml:lang="grc"><supplied reason="lost">Jon</supplied></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    #above tests without lang attribute
    assert_equal_fragment_transform '<:Jon(?)|reg|Jan:>', '<choice><reg cert="low">Jon</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|reg|[Jan](?):>', '<choice><reg cert="low">Jon</reg><orig><supplied reason="lost">Jan</supplied><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon(?)|reg|[Jan]:>', '<choice><reg cert="low">Jon</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[Jon](?)|reg|Jan:>', '<choice><reg cert="low"><supplied reason="lost">Jon</supplied></reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:[Jon](?)|reg|[Jan](?):>', '<choice><reg cert="low"><supplied reason="lost">Jon</supplied></reg><orig><supplied reason="lost">Jan</supplied><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:[Jon](?)|reg|[Jan]:>', '<choice><reg cert="low"><supplied reason="lost">Jon</supplied></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:Jon|reg|Jan:>', '<choice><reg>Jon</reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:Jon|reg|[Jan](?):>', '<choice><reg>Jon</reg><orig><supplied reason="lost">Jan</supplied><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:Jon|reg|[Jan]:>', '<choice><reg>Jon</reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
    assert_equal_fragment_transform '<:[Jon]|reg|Jan:>', '<choice><reg><supplied reason="lost">Jon</supplied></reg><orig>Jan</orig></choice>'
    assert_equal_fragment_transform '<:[Jon]|reg|[Jan](?):>', '<choice><reg><supplied reason="lost">Jon</supplied></reg><orig><supplied reason="lost">Jan</supplied><certainty match=".." locus="value"/></orig></choice>'
    assert_equal_fragment_transform '<:[Jon]|reg|[Jan]:>', '<choice><reg><supplied reason="lost">Jon</supplied></reg><orig><supplied reason="lost">Jan</supplied></orig></choice>'
  end
  
  def test_subst
    assert_equal_fragment_transform '<:Silvanus(?)|subst|silvanos(?):>', '<subst><add place="inline">Silvanus<certainty match=".." locus="value"/></add><del rend="corrected">silvanos<certainty match=".." locus="value"/></del></subst>'
    assert_equal_fragment_transform '<:a|subst|b:>', '<subst><add place="inline">a</add><del rend="corrected">b</del></subst>'
    assert_equal_fragment_transform '<:abcd(?)|subst|b:>', '<subst><add place="inline">abcd<certainty match=".." locus="value"/></add><del rend="corrected">b</del></subst>'
    assert_equal_fragment_transform '<:τὸ̣|subst|τα (?):>', '<subst><add place="inline">τ<unclear>ὸ</unclear></add><del rend="corrected">τα <certainty match=".." locus="value"/></del></subst>'
    assert_equal_fragment_transform '<:τὸ̣(?)|subst|τα :>', '<subst><add place="inline">τ<unclear>ὸ</unclear><certainty match=".." locus="value"/></add><del rend="corrected">τα </del></subst>'
    assert_equal_fragment_transform '<:τὸ̣(?)|subst|τα (?):>', '<subst><add place="inline">τ<unclear>ὸ</unclear><certainty match=".." locus="value"/></add><del rend="corrected">τα <certainty match=".." locus="value"/></del></subst>'
  end
  
  def test_app_lem
    assert_equal_fragment_transform '<:[μου][μάμ]μη|alt|[.5][διδύ(?)]μη(?):>', '<app type="alternative"><lem><supplied reason="lost">μου</supplied><supplied reason="lost">μάμ</supplied>μη</lem><rdg><gap reason="lost" quantity="5" unit="character"/><supplied reason="lost" cert="low">διδύ</supplied>μη<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:[καθ]ὰ(?)|alt|[.2]α:>', '<app type="alternative"><lem><supplied reason="lost">καθ</supplied>ὰ<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α</rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)|alt|[.2]α(?):>', '<app type="alternative"><lem><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:〚κ〛 (?)|alt|:>', '<app type="alternative"><lem><del rend="erasure">κ</del> <certainty match=".." locus="value"/></lem><rdg/></app>'
    assert_equal_fragment_transform '<:|alt|〚κ〛 (?):>', '<app type="alternative"><lem/><rdg><del rend="erasure">κ</del> <certainty match=".." locus="value"/></rdg></app>'
  end
    
  def test_alt
    assert_equal_fragment_transform '<:[μου][μάμ]μη|alt|[.5][διδύ(?)]μη(?):>', '<app type="alternative"><lem><supplied reason="lost">μου</supplied><supplied reason="lost">μάμ</supplied>μη</lem><rdg><gap reason="lost" quantity="5" unit="character"/><supplied reason="lost" cert="low">διδύ</supplied>μη<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:[καθ]ὰ(?)|alt|[.2]α:>', '<app type="alternative"><lem><supplied reason="lost">καθ</supplied>ὰ<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α</rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)|alt|[.2]α(?):>', '<app type="alternative"><lem><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:〚κ〛 (?)|alt|:>', '<app type="alternative"><lem><del rend="erasure">κ</del> <certainty match=".." locus="value"/></lem><rdg/></app>'
    assert_equal_fragment_transform '<:|alt|〚κ〛 (?):>', '<app type="alternative"><lem/><rdg><del rend="erasure">κ</del> <certainty match=".." locus="value"/></rdg></app>'
  end
  
  def test_mult_alt_rdgs
    assert_equal_fragment_transform '<:James Jaymes Jomes|alt|Jeames:>', '<app type="alternative"><lem>James Jaymes Jomes</lem><rdg>Jeames</rdg></app>'
    assert_equal_fragment_transform '<:Jan||alt||Jon|Jean|Jun|John:>', '<app type="alternative"><lem>Jan</lem><rdg>Jon</rdg><rdg>Jean</rdg><rdg>Jun</rdg><rdg>John</rdg></app>'
    assert_equal_fragment_transform '<:Jan||alt||Jon(?)|Jean|Jun(?)|John:>', '<app type="alternative"><lem>Jan</lem><rdg>Jon<certainty match=".." locus="value"/></rdg><rdg>Jean</rdg><rdg>Jun<certainty match=".." locus="value"/></rdg><rdg>John</rdg></app>'
    assert_equal_fragment_transform '<:J[a]n||alt||J[o]n|Jean|Jun|Jo[h]n:>', '<app type="alternative"><lem>J<supplied reason="lost">a</supplied>n</lem><rdg>J<supplied reason="lost">o</supplied>n</rdg><rdg>Jean</rdg><rdg>Jun</rdg><rdg>Jo<supplied reason="lost">h</supplied>n</rdg></app>'
    assert_equal_fragment_transform '<:J[a]n||alt||J[o]n(?)|Jean|Jun(?)|Jo[h]n:>', '<app type="alternative"><lem>J<supplied reason="lost">a</supplied>n</lem><rdg>J<supplied reason="lost">o</supplied>n<certainty match=".." locus="value"/></rdg><rdg>Jean</rdg><rdg>Jun<certainty match=".." locus="value"/></rdg><rdg>Jo<supplied reason="lost">h</supplied>n</rdg></app>'
    assert_equal_fragment_transform '<:Jan(?)||alt||Jon|Jean|Jun|John:>', '<app type="alternative"><lem>Jan<certainty match=".." locus="value"/></lem><rdg>Jon</rdg><rdg>Jean</rdg><rdg>Jun</rdg><rdg>John</rdg></app>'
    assert_equal_fragment_transform '<:Jan(?)||alt||Jon(?)|Jean|Jun(?)|John:>', '<app type="alternative"><lem>Jan<certainty match=".." locus="value"/></lem><rdg>Jon<certainty match=".." locus="value"/></rdg><rdg>Jean</rdg><rdg>Jun<certainty match=".." locus="value"/></rdg><rdg>John</rdg></app>'
    assert_equal_fragment_transform '<:J[a]n(?)||alt||J[o]n|Jean|Jun|Jo[h]n:>', '<app type="alternative"><lem>J<supplied reason="lost">a</supplied>n<certainty match=".." locus="value"/></lem><rdg>J<supplied reason="lost">o</supplied>n</rdg><rdg>Jean</rdg><rdg>Jun</rdg><rdg>Jo<supplied reason="lost">h</supplied>n</rdg></app>'
    assert_equal_fragment_transform '<:J[a]n(?)||alt||J[o]n(?)|Jean|Jun(?)|Jo[h]n:>', '<app type="alternative"><lem>J<supplied reason="lost">a</supplied>n<certainty match=".." locus="value"/></lem><rdg>J<supplied reason="lost">o</supplied>n<certainty match=".." locus="value"/></rdg><rdg>Jean</rdg><rdg>Jun<certainty match=".." locus="value"/></rdg><rdg>Jo<supplied reason="lost">h</supplied>n</rdg></app>'
  end
   
  def test_mult_alt_rdgs_with_tall
    assert_equal_fragment_transform '<:Jeames|alt|James~||Jaymes||~tallJomes:>', '<app type="alternative"><lem>Jeames</lem><rdg>James<hi rend="tall">Jaymes</hi>Jomes</rdg></app>'
    assert_equal_fragment_transform '<:Jeames||alt||Jimes|James~||Jaymes||~tallJomes:>', '<app type="alternative"><lem>Jeames</lem><rdg>Jimes</rdg><rdg>James<hi rend="tall">Jaymes</hi>Jomes</rdg></app>'
  end
  
=begin # Hugh start of commented new app lem with resp= test
  def test_new_alternative
    #new ed format
    assert_equal_fragment_transform '<:a=bgu 3 p.4|alt|b:>', '<app type="alternative"><lem resp="bgu 3 p.4">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:[μου][μάμ]μη=2.14|alt|[.5][διδύ(?)]μη(?):>', '<app type="alternative"><lem resp="2.14"><supplied reason="lost">μου</supplied><supplied reason="lost">μάμ</supplied>μη</lem><rdg><gap reason="lost" quantity="5" unit="character"/><supplied reason="lost" cert="low">διδύ</supplied>μη<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:[καθ]ὰ(?)=bgu 1 p.357|alt|[.2]α:>', '<app type="alternative"><lem resp="bgu 1 p.357"><supplied reason="lost">καθ</supplied>ὰ<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α</rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)=1.27|alt|[.2]α(?):>', '<app type="alternative"><lem resp="1.27"><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:〚κ〛 (?)=1.24|alt|:>', '<app type="alternative"><lem resp="1.24"><del rend="erasure">κ</del> <certainty match=".." locus="value"/></lem><rdg/></app>'
    assert_equal_fragment_transform '<:〚κ〛 =1.24|alt|:>', '<app type="alternative"><lem resp="1.24"><del rend="erasure">κ</del> </lem><rdg/></app>'
    assert_equal_fragment_transform '<:[μου][μάμ]μη|alt|[.5][διδύ(?)]μη(?):>', '<app type="alternative"><lem><supplied reason="lost">μου</supplied><supplied reason="lost">μάμ</supplied>μη</lem><rdg><gap reason="lost" quantity="5" unit="character"/><supplied reason="lost" cert="low">διδύ</supplied>μη<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:[καθ]ὰ(?)|alt|[.2]α:>', '<app type="alternative"><lem><supplied reason="lost">καθ</supplied>ὰ<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α</rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)|alt|[.2]α(?):>', '<app type="alternative"><lem><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:〚κ〛 (?)|alt|:>', '<app type="alternative"><lem><del rend="erasure">κ</del> <certainty match=".." locus="value"/></lem><rdg/></app>'
    assert_equal_fragment_transform '<:〚κ〛 |alt|:>', '<app type="alternative"><lem><del rend="erasure">κ</del> </lem><rdg/></app>'
    #new SoSOL format
    assert_equal_fragment_transform '<:πέπρα 23.- κα ὡς <(πρόκ(ειται))>. (ἔγ(ρα))ψα Μύσ̣θη̣ς (Μέλαν(ος)) <(ὑπ(ὲρ))> (αὐ̣(τοῦ)) μὴ (εἰδ̣(ότος)) (γρ(άμματα))=SoSOL Cowey|alt|.4κ̣.3εγψα.4.4.2:>', '<app type="alternative"><lem resp="SoSOL Cowey">πέπρα <lb n="23" break="no"/>κα ὡς <supplied reason="omitted"><expan>πρόκ<ex>ειται</ex></expan></supplied>. <expan>ἔγ<ex>ρα</ex></expan>ψα Μύ<unclear>σ</unclear>θ<unclear>η</unclear>ς <expan>Μέλαν<ex>ος</ex></expan> <supplied reason="omitted"><expan>ὑπ<ex>ὲρ</ex></expan></supplied> <expan>α<unclear>ὐ</unclear><ex>τοῦ</ex></expan> μὴ <expan>εἰ<unclear>δ</unclear><ex>ότος</ex></expan> <expan>γρ<ex>άμματα</ex></expan></lem><rdg><gap reason="illegible" quantity="4" unit="character"/><unclear>κ</unclear><gap reason="illegible" quantity="3" unit="character"/>εγψα<gap reason="illegible" quantity="4" unit="character"/><gap reason="illegible" quantity="4" unit="character"/><gap reason="illegible" quantity="2" unit="character"/></rdg></app>'
    assert_equal_fragment_transform '<:[.?]<#λβ=32#> .2 ἐκ <((ταλάντων))> <#κζ=27#> <((δραχμῶν))> <#Γ=3000#> ((τάλαντα)) <#ωοθ=879#> <((δραχμαὶ))> <#Γσ=3200#>=SoSOL Sosin|alt|[.?]<#λβ=32#> <#𐅵 \'=1/2#> <#ιβ \'=1/12#> ἐκ ((ταλάντων)) <#ζ=7#> <#Γ=3000#> ((τάλαντα)) <#ωοθ=879#> <#η \'=1/8(?)#>:>', '<app type="alternative"><lem resp="SoSOL Sosin"><gap reason="lost" extent="unknown" unit="character"/><num value="32">λβ</num> <gap reason="illegible" quantity="2" unit="character"/> ἐκ <supplied reason="omitted"><expan><ex>ταλάντων</ex></expan></supplied> <num value="27">κζ</num> <supplied reason="omitted"><expan><ex>δραχμῶν</ex></expan></supplied> <num value="3000">Γ</num> <expan><ex>τάλαντα</ex></expan> <num value="879">ωοθ</num> <supplied reason="omitted"><expan><ex>δραχμαὶ</ex></expan></supplied> <num value="3200">Γσ</num></lem><rdg><gap reason="lost" extent="unknown" unit="character"/><num value="32">λβ</num> <num value="1/2" rend="tick">𐅵</num> <num value="1/12" rend="tick">ιβ</num> ἐκ <expan><ex>ταλάντων</ex></expan> <num value="7">ζ</num> <num value="3000">Γ</num> <expan><ex>τάλαντα</ex></expan> <num value="879">ωοθ</num> <num value="1/8" rend="tick">η<certainty match="../@value" locus="value"/></num></rdg></app>'
    assert_equal_fragment_transform '<:〚(Λεόντ(ιος)) (Σεν̣ο̣[υθί(ου)])[ Σενουθίου ][.?] 〛=SoSOL Ast|alt|(Σενούθ(ιος)) \vestig / (Σενουθ(ίου)) vestig :>', '<app type="alternative"><lem resp="SoSOL Ast"><del rend="erasure"><expan>Λεόντ<ex>ιος</ex></expan> <expan>Σε<unclear>νο</unclear><supplied reason="lost">υθί<ex>ου</ex></supplied></expan><supplied reason="lost"> Σενουθίου </supplied><gap reason="lost" extent="unknown" unit="character"/> </del></lem><rdg><expan>Σενούθ<ex>ιος</ex></expan> <add place="above"><gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></add> <expan>Σενουθ<ex>ίου</ex></expan> <gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></rdg></app>'
    assert_equal_fragment_transform '<:<#α=1#>\|<#ι=10#>|/ <#α=1#>\|<#ξ=60#>|/ <#α=1#>\|<#ρκ=120#>|/=SoSOL Cayless|alt|<#β=2#> <#𐅵 \'=1/2#> <#ξδ \'=1/64#>:>', '<app type="alternative"><lem resp="SoSOL Cayless"><num value="1">α</num><hi rend="subscript"><num value="10">ι</num></hi> <num value="1">α</num><hi rend="subscript"><num value="60">ξ</num></hi> <num value="1">α</num><hi rend="subscript"><num value="120">ρκ</num></hi></lem><rdg><num value="2">β</num> <num value="1/2" rend="tick">𐅵</num> <num value="1/64" rend="tick">ξδ</num></rdg></app>'
    assert_equal_fragment_transform '<:καὶ <:<καν(?)>ονικῶν(?)|corr|ονι̣κ̣ων:>=SoSOL Elliott|alt|καιονι̣κ̣ων:>', '<app type="alternative"><lem resp="SoSOL Elliott">καὶ <choice><corr cert="low"><supplied reason="omitted" cert="low">καν</supplied>ονικῶν</corr><sic>ον<unclear>ικ</unclear>ων</sic></choice></lem><rdg>καιον<unclear>ικ</unclear>ων</rdg></app>'
    assert_equal_fragment_transform '<:[καὶ ὧν δε]κάτη [27]<#β=2#>=SoSOL Gabby|alt|[.6]ων.2[.2]<#β=2#>:>', '<app type="alternative"><lem resp="SoSOL Gabby"><supplied reason="lost">καὶ ὧν δε</supplied>κάτη <supplied reason="lost">27</supplied><num value="2">β</num></lem><rdg><gap reason="lost" quantity="6" unit="character"/>ων<gap reason="illegible" quantity="2" unit="character"/><gap reason="lost" quantity="2" unit="character"/><num value="2">β</num></rdg></app>'
    assert_equal_fragment_transform '<:(Κών̣ων̣(ος))=SoSOL Fox|alt|Κω.2ω <:vestig |corr|*monogram*:>:>', '<app type="alternative"><lem resp="SoSOL Fox"><expan>Κώ<unclear>ν</unclear>ω<unclear>ν</unclear><ex>ος</ex></expan></lem><rdg>Κω<gap reason="illegible" quantity="2" unit="character"/>ω <choice><corr><gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></corr><sic><g type="monogram"/></sic></choice></rdg></app>'
    assert_equal_fragment_transform '\<:.3(|ομ|)=SoSOL Sosin|alt|ε.1ε.2:>/', '<add place="above"><app type="alternative"><lem resp="SoSOL Sosin"><gap reason="illegible" quantity="3" unit="character"/><abbr>ομ</abbr></lem><rdg>ε<gap reason="illegible" quantity="1" unit="character"/>ε<gap reason="illegible" quantity="2" unit="character"/></rdg></app></add>'
    #new BL format
    assert_equal_fragment_transform '<:a=BL 1.215|alt|b:>', '<app type="alternative"><lem resp="BL 1.215">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:[μου][μάμ]μη=BL 2.14|alt|[.5][διδύ(?)]μη(?):>', '<app type="alternative"><lem resp="BL 2.14"><supplied reason="lost">μου</supplied><supplied reason="lost">μάμ</supplied>μη</lem><rdg><gap reason="lost" quantity="5" unit="character"/><supplied reason="lost" cert="low">διδύ</supplied>μη<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)=BL 1.27|alt|η̣μο.2:>', '<app type="alternative"><lem resp="BL 1.27"><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><unclear>η</unclear>μο<gap reason="illegible" quantity="2" unit="character"/></rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)=BL 1.27|alt|[.2]α(?):>', '<app type="alternative"><lem resp="BL 1.27"><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:〚κ〛 (?)=BL 1.24|alt|:>', '<app type="alternative"><lem resp="BL 1.24"><del rend="erasure">κ</del> <certainty match=".." locus="value"/></lem><rdg/></app>'
    #
    assert_equal_fragment_transform '<:ὑπηR 8.- [ρετῶ]ν=bgu 3 p.1|alt|[.7]ν:>', '<app type="alternative"><lem resp="bgu 3 p.1">ὑπηR <lb n="8" break="no"/><supplied reason="lost">ρετῶ</supplied>ν</lem><rdg><gap reason="lost" quantity="7" unit="character"/>ν</rdg></app>'
    assert_equal_fragment_transform '<:Πα[νε]φρόμ 23.- μεως|alt|Πα[νε]φρέμμεως:>', '<app type="alternative"><lem>Πα<supplied reason="lost">νε</supplied>φρόμ <lb n="23" break="no"/>μεως</lem><rdg>Πα<supplied reason="lost">νε</supplied>φρέμμεως</rdg></app>'
    assert_equal_fragment_transform '<:Πα[νε]φρόμ (2.-, inverse)μεως|alt|Πα[νε]φρέμμεως:>', '<app type="alternative"><lem>Πα<supplied reason="lost">νε</supplied>φρόμ <lb n="2" rend="inverse" break="no"/>μεως</lem><rdg>Πα<supplied reason="lost">νε</supplied>φρέμμεως</rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=BL 12.2|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=SoSOL 12.2|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem resp="SoSOL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=SoSOL 12.2|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem resp="SoSOL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem>στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem>στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|alt|Συ̣ρ[ίων]=Original Edition:>', '<app type="alternative"><lem resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηλάτης]=J. Cowey, ZPE 123 (1999) 321-323|alt|Συ̣ρ[ίων]=Original Edition:>', '<app type="alternative"><lem resp="J. Cowey, ZPE 123 (1999) 321-323">στρ<supplied reason="lost">ατηλάτης</supplied></lem><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηλάτης]=J. Cowey, ZPE 123 (1999) 321-323|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem resp="J. Cowey, ZPE 123 (1999) 321-323">στρ<supplied reason="lost">ατηλάτης</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2|alt|Συ̣ρ[ίων]=Original Edition:>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:Στρ[άβων]=SoSOL J. Sosin (autopsy)|alt|Συ̣ρ[ίων]=Original Edition:>', '<app type="alternative"><lem resp="SoSOL J. Sosin (autopsy)">Στρ<supplied reason="lost">άβων</supplied></lem><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:Στρ[άβων]=SoSOL J. Sosin (autopsy)|alt|Συ̣ρ[ίων]:>', '<app type="alternative"><lem resp="SoSOL J. Sosin (autopsy)">Στρ<supplied reason="lost">άβων</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2||alt||στρ[ατηλάτης]=J. Cowey, ZPE 123 (1999) 321-323|στρ[ατιώτης]=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|Στρ[άβων]=SoSOL Sosin|Συ̣ρ[ίων]=Original Edition:>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="J. Cowey, ZPE 123 (1999) 321-323">στρ<supplied reason="lost">ατηλάτης</supplied></rdg><rdg resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)">στρ<supplied reason="lost">ατιώτης</supplied></rdg><rdg resp="SoSOL Sosin">Στρ<supplied reason="lost">άβων</supplied></rdg><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2||alt||στρ[ατηλάτης]=J. Cowey, ZPE 123 (1999) 321-323|<:στρ[ατιώτης]|reg|στυ̣ρ[ατιώτης]:>=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|Συ̣ρ[ίων]=Original Edition:>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="J. Cowey, ZPE 123 (1999) 321-323">στρ<supplied reason="lost">ατηλάτης</supplied></rdg><rdg resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)"><choice><reg>στρ<supplied reason="lost">ατιώτης</supplied></reg><orig>στ<unclear>υ</unclear>ρ<supplied reason="lost">ατιώτης</supplied></orig></choice></rdg><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2||alt||<:στρ[ατηλάτης]|alt|στρ[ιππερς]:>=J. Cowey, ZPE 123 (1999) 321-323|<:στρ[ατιώτης]|reg|στυ̣ρ[ατιώτης]:>=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|Συ̣ρ[ίων]=Original Edition:>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="J. Cowey, ZPE 123 (1999) 321-323"><app type="alternative"><lem>στρ<supplied reason="lost">ατηλάτης</supplied></lem><rdg>στρ<supplied reason="lost">ιππερς</supplied></rdg></app></rdg><rdg resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)"><choice><reg>στρ<supplied reason="lost">ατιώτης</supplied></reg><orig>στ<unclear>υ</unclear>ρ<supplied reason="lost">ατιώτης</supplied></orig></choice></rdg><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=BL 12.2||alt||<:στρ[ατηλάτης]|alt|στρ[ιππερς]:>(?)=J. Cowey, ZPE 123 (1999) 321-323|<:στρ[ατιώτης]|reg|στυ̣ρ[ατιώτης]:>(?)=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|Συ̣ρ[ίων](?)=Original Edition:>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg resp="J. Cowey, ZPE 123 (1999) 321-323"><app type="alternative"><lem>στρ<supplied reason="lost">ατηλάτης</supplied></lem><rdg>στρ<supplied reason="lost">ιππερς</supplied></rdg></app><certainty match=".." locus="value"/></rdg><rdg resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)"><choice><reg>στρ<supplied reason="lost">ατιώτης</supplied></reg><orig>στ<unclear>υ</unclear>ρ<supplied reason="lost">ατιώτης</supplied></orig></choice><certainty match=".." locus="value"/></rdg><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2|alt|Συ̣ρ[ίων](?):>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=BL 12.2|alt|Συ̣ρ[ίων](?):>', '<app type="alternative"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=SoSOL 12.2|alt|Συ̣ρ[ίων](?):>', '<app type="alternative"><lem resp="SoSOL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=SoSOL 12.2|alt|Συ̣ρ[ίων](?):>', '<app type="alternative"><lem resp="SoSOL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]|alt|Συ̣ρ[ίων](?):>', '<app type="alternative"><lem>στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)|alt|Συ̣ρ[ίων](?):>', '<app type="alternative"><lem>στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    #
    assert_equal_fragment_transform '<:a=BL 1.215|alt|b:>', '<app type="alternative"><lem resp="BL 1.215">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:a=SoSOL 1.215|alt|b:>', '<app type="alternative"><lem resp="SoSOL 1.215">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:a=J. Cowey, ZPE 123 (1999) 321-323|alt|b:>', '<app type="alternative"><lem resp="J. Cowey, ZPE 123 (1999) 321-323">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:a=BL 1.215|alt|:>', '<app type="alternative"><lem resp="BL 1.215">a</lem><rdg/></app>'
    assert_equal_fragment_transform '<:a=BL 1.215|alt|=Original Editor:>', '<app type="alternative"><lem resp="BL 1.215">a</lem><rdg resp="Original Editor"/></app>'
    assert_equal_fragment_transform '<:=BL 1.215|alt|b:>', '<app type="alternative"><lem resp="BL 1.215"/><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:|alt|b:>', '<app type="alternative"><lem/><rdg>b</rdg></app>'
  end
=end # Hugh end of commented new app lem with resp= test
  
  def test_new_editorial
    #new ed format
    assert_equal_fragment_transform '<:a=bgu 3 p.4|ed|b:>', '<app type="editorial"><lem resp="bgu 3 p.4">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:[μου][μάμ]μη=2.14|ed|[.5][διδύ(?)]μη(?):>', '<app type="editorial"><lem resp="2.14"><supplied reason="lost">μου</supplied><supplied reason="lost">μάμ</supplied>μη</lem><rdg><gap reason="lost" quantity="5" unit="character"/><supplied reason="lost" cert="low">διδύ</supplied>μη<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:[καθ]ὰ(?)=bgu 1 p.357|ed|[.2]α:>', '<app type="editorial"><lem resp="bgu 1 p.357"><supplied reason="lost">καθ</supplied>ὰ<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α</rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)=1.27|ed|[.2]α(?):>', '<app type="editorial"><lem resp="1.27"><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:〚κ〛 (?)=1.24|ed|:>', '<app type="editorial"><lem resp="1.24"><del rend="erasure">κ</del> <certainty match=".." locus="value"/></lem><rdg/></app>'
    assert_equal_fragment_transform '<:〚κ〛 =1.24|ed|:>', '<app type="editorial"><lem resp="1.24"><del rend="erasure">κ</del> </lem><rdg/></app>'
    assert_equal_fragment_transform '<:[μου][μάμ]μη|ed|[.5][διδύ(?)]μη(?):>', '<app type="editorial"><lem><supplied reason="lost">μου</supplied><supplied reason="lost">μάμ</supplied>μη</lem><rdg><gap reason="lost" quantity="5" unit="character"/><supplied reason="lost" cert="low">διδύ</supplied>μη<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:[καθ]ὰ(?)|ed|[.2]α:>', '<app type="editorial"><lem><supplied reason="lost">καθ</supplied>ὰ<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α</rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)|ed|[.2]α(?):>', '<app type="editorial"><lem><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:〚κ〛 (?)|ed|:>', '<app type="editorial"><lem><del rend="erasure">κ</del> <certainty match=".." locus="value"/></lem><rdg/></app>'
    assert_equal_fragment_transform '<:〚κ〛 |ed|:>', '<app type="editorial"><lem><del rend="erasure">κ</del> </lem><rdg/></app>'
    #new SoSOL format
    assert_equal_fragment_transform '<:πέπρα 23.- κα ὡς <(πρόκ(ειται))>. (ἔγ(ρα))ψα Μύσ̣θη̣ς (Μέλαν(ος)) <(ὑπ(ὲρ))> (αὐ̣(τοῦ)) μὴ (εἰδ̣(ότος)) (γρ(άμματα))=SoSOL Cowey|ed|.4κ̣.3εγψα.4.4.2:>', '<app type="editorial"><lem resp="SoSOL Cowey">πέπρα <lb n="23" break="no"/>κα ὡς <supplied reason="omitted"><expan>πρόκ<ex>ειται</ex></expan></supplied>. <expan>ἔγ<ex>ρα</ex></expan>ψα Μύ<unclear>σ</unclear>θ<unclear>η</unclear>ς <expan>Μέλαν<ex>ος</ex></expan> <supplied reason="omitted"><expan>ὑπ<ex>ὲρ</ex></expan></supplied> <expan>α<unclear>ὐ</unclear><ex>τοῦ</ex></expan> μὴ <expan>εἰ<unclear>δ</unclear><ex>ότος</ex></expan> <expan>γρ<ex>άμματα</ex></expan></lem><rdg><gap reason="illegible" quantity="4" unit="character"/><unclear>κ</unclear><gap reason="illegible" quantity="3" unit="character"/>εγψα<gap reason="illegible" quantity="4" unit="character"/><gap reason="illegible" quantity="4" unit="character"/><gap reason="illegible" quantity="2" unit="character"/></rdg></app>'
    assert_equal_fragment_transform '<:[.?]<#λβ=32#> .2 ἐκ <((ταλάντων))> <#κζ=27#> <((δραχμῶν))> <#Γ=3000#> ((τάλαντα)) <#ωοθ=879#> <((δραχμαὶ))> <#Γσ=3200#>=SoSOL Sosin|ed|[.?]<#λβ=32#> <#𐅵 \'=1/2#> <#ιβ \'=1/12#> ἐκ ((ταλάντων)) <#ζ=7#> <#Γ=3000#> ((τάλαντα)) <#ωοθ=879#> <#η \'=1/8(?)#>:>', '<app type="editorial"><lem resp="SoSOL Sosin"><gap reason="lost" extent="unknown" unit="character"/><num value="32">λβ</num> <gap reason="illegible" quantity="2" unit="character"/> ἐκ <supplied reason="omitted"><expan><ex>ταλάντων</ex></expan></supplied> <num value="27">κζ</num> <supplied reason="omitted"><expan><ex>δραχμῶν</ex></expan></supplied> <num value="3000">Γ</num> <expan><ex>τάλαντα</ex></expan> <num value="879">ωοθ</num> <supplied reason="omitted"><expan><ex>δραχμαὶ</ex></expan></supplied> <num value="3200">Γσ</num></lem><rdg><gap reason="lost" extent="unknown" unit="character"/><num value="32">λβ</num> <num value="1/2" rend="tick">𐅵</num> <num value="1/12" rend="tick">ιβ</num> ἐκ <expan><ex>ταλάντων</ex></expan> <num value="7">ζ</num> <num value="3000">Γ</num> <expan><ex>τάλαντα</ex></expan> <num value="879">ωοθ</num> <num value="1/8" rend="tick">η<certainty match="../@value" locus="value"/></num></rdg></app>'
    assert_equal_fragment_transform '<:〚(Λεόντ(ιος)) (Σεν̣ο̣[υθί(ου)])[ Σενουθίου ][.?] 〛=SoSOL Ast|ed|(Σενούθ(ιος)) \vestig / (Σενουθ(ίου)) vestig :>', '<app type="editorial"><lem resp="SoSOL Ast"><del rend="erasure"><expan>Λεόντ<ex>ιος</ex></expan> <expan>Σε<unclear>νο</unclear><supplied reason="lost">υθί<ex>ου</ex></supplied></expan><supplied reason="lost"> Σενουθίου </supplied><gap reason="lost" extent="unknown" unit="character"/> </del></lem><rdg><expan>Σενούθ<ex>ιος</ex></expan> <add place="above"><gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></add> <expan>Σενουθ<ex>ίου</ex></expan> <gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></rdg></app>'
    assert_equal_fragment_transform '<:<#α=1#>\|<#ι=10#>|/ <#α=1#>\|<#ξ=60#>|/ <#α=1#>\|<#ρκ=120#>|/=SoSOL Cayless|ed|<#β=2#> <#𐅵 \'=1/2#> <#ξδ \'=1/64#>:>', '<app type="editorial"><lem resp="SoSOL Cayless"><num value="1">α</num><hi rend="subscript"><num value="10">ι</num></hi> <num value="1">α</num><hi rend="subscript"><num value="60">ξ</num></hi> <num value="1">α</num><hi rend="subscript"><num value="120">ρκ</num></hi></lem><rdg><num value="2">β</num> <num value="1/2" rend="tick">𐅵</num> <num value="1/64" rend="tick">ξδ</num></rdg></app>'
    assert_equal_fragment_transform '<:καὶ <:<καν(?)>ονικῶν(?)|corr|ονι̣κ̣ων:>=SoSOL Elliott|ed|καιονι̣κ̣ων:>', '<app type="editorial"><lem resp="SoSOL Elliott">καὶ <choice><corr cert="low"><supplied reason="omitted" cert="low">καν</supplied>ονικῶν</corr><sic>ον<unclear>ικ</unclear>ων</sic></choice></lem><rdg>καιον<unclear>ικ</unclear>ων</rdg></app>'
    assert_equal_fragment_transform '<:[καὶ ὧν δε]κάτη [27]<#β=2#>=SoSOL Gabby|ed|[.6]ων.2[.2]<#β=2#>:>', '<app type="editorial"><lem resp="SoSOL Gabby"><supplied reason="lost">καὶ ὧν δε</supplied>κάτη <supplied reason="lost">27</supplied><num value="2">β</num></lem><rdg><gap reason="lost" quantity="6" unit="character"/>ων<gap reason="illegible" quantity="2" unit="character"/><gap reason="lost" quantity="2" unit="character"/><num value="2">β</num></rdg></app>'
    assert_equal_fragment_transform '<:(Κών̣ων̣(ος))=SoSOL Fox|ed|Κω.2ω <:vestig |corr|*monogram*:>:>', '<app type="editorial"><lem resp="SoSOL Fox"><expan>Κώ<unclear>ν</unclear>ω<unclear>ν</unclear><ex>ος</ex></expan></lem><rdg>Κω<gap reason="illegible" quantity="2" unit="character"/>ω <choice><corr><gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></corr><sic><g type="monogram"/></sic></choice></rdg></app>'
    assert_equal_fragment_transform '\<:.3(|ομ|)=SoSOL Sosin|ed|ε.1ε.2:>/', '<add place="above"><app type="editorial"><lem resp="SoSOL Sosin"><gap reason="illegible" quantity="3" unit="character"/><abbr>ομ</abbr></lem><rdg>ε<gap reason="illegible" quantity="1" unit="character"/>ε<gap reason="illegible" quantity="2" unit="character"/></rdg></app></add>'
    #new BL format
    assert_equal_fragment_transform '<:a=BL 1.215|ed|b:>', '<app type="editorial"><lem resp="BL 1.215">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:[μου][μάμ]μη=BL 2.14|ed|[.5][διδύ(?)]μη(?):>', '<app type="editorial"><lem resp="BL 2.14"><supplied reason="lost">μου</supplied><supplied reason="lost">μάμ</supplied>μη</lem><rdg><gap reason="lost" quantity="5" unit="character"/><supplied reason="lost" cert="low">διδύ</supplied>μη<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)=BL 1.27|ed|η̣μο.2:>', '<app type="editorial"><lem resp="BL 1.27"><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><unclear>η</unclear>μο<gap reason="illegible" quantity="2" unit="character"/></rdg></app>'
    assert_equal_fragment_transform '<:σ̣υ̣μβολικά(?)=BL 1.27|ed|[.2]α(?):>', '<app type="editorial"><lem resp="BL 1.27"><unclear>συ</unclear>μβολικά<certainty match=".." locus="value"/></lem><rdg><gap reason="lost" quantity="2" unit="character"/>α<certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:〚κ〛 (?)=BL 1.24|ed|:>', '<app type="editorial"><lem resp="BL 1.24"><del rend="erasure">κ</del> <certainty match=".." locus="value"/></lem><rdg/></app>'
    #
    assert_equal_fragment_transform '<:ὑπηR 8.- [ρετῶ]ν=bgu 3 p.1|ed|[.7]ν:>', '<app type="editorial"><lem resp="bgu 3 p.1">ὑπηR <lb n="8" break="no"/><supplied reason="lost">ρετῶ</supplied>ν</lem><rdg><gap reason="lost" quantity="7" unit="character"/>ν</rdg></app>'
    assert_equal_fragment_transform '<:Πα[νε]φρόμ 23.- μεως|ed|Πα[νε]φρέμμεως:>', '<app type="editorial"><lem>Πα<supplied reason="lost">νε</supplied>φρόμ <lb n="23" break="no"/>μεως</lem><rdg>Πα<supplied reason="lost">νε</supplied>φρέμμεως</rdg></app>'
    assert_equal_fragment_transform '<:Πα[νε]φρόμ (2.-, inverse)μεως|ed|Πα[νε]φρέμμεως:>', '<app type="editorial"><lem>Πα<supplied reason="lost">νε</supplied>φρόμ <lb n="2" rend="inverse" break="no"/>μεως</lem><rdg>Πα<supplied reason="lost">νε</supplied>φρέμμεως</rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=BL 12.2|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=SoSOL 12.2|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem resp="SoSOL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=SoSOL 12.2|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem resp="SoSOL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem>στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem>στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|ed|Συ̣ρ[ίων]=Original Edition:>', '<app type="editorial"><lem resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηλάτης]=J. Cowey, ZPE 123 (1999) 321-323|ed|Συ̣ρ[ίων]=Original Edition:>', '<app type="editorial"><lem resp="J. Cowey, ZPE 123 (1999) 321-323">στρ<supplied reason="lost">ατηλάτης</supplied></lem><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηλάτης]=J. Cowey, ZPE 123 (1999) 321-323|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem resp="J. Cowey, ZPE 123 (1999) 321-323">στρ<supplied reason="lost">ατηλάτης</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2|ed|Συ̣ρ[ίων]=Original Edition:>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:Στρ[άβων]=SoSOL J. Sosin (autopsy)|ed|Συ̣ρ[ίων]=Original Edition:>', '<app type="editorial"><lem resp="SoSOL J. Sosin (autopsy)">Στρ<supplied reason="lost">άβων</supplied></lem><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    assert_equal_fragment_transform '<:Στρ[άβων]=SoSOL J. Sosin (autopsy)|ed|Συ̣ρ[ίων]:>', '<app type="editorial"><lem resp="SoSOL J. Sosin (autopsy)">Στρ<supplied reason="lost">άβων</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2||ed||στρ[ατηλάτης]=J. Cowey, ZPE 123 (1999) 321-323|στρ[ατιώτης]=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|Στρ[άβων]=SoSOL Sosin|Συ̣ρ[ίων]=Original Edition:>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="J. Cowey, ZPE 123 (1999) 321-323">στρ<supplied reason="lost">ατηλάτης</supplied></rdg><rdg resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)">στρ<supplied reason="lost">ατιώτης</supplied></rdg><rdg resp="SoSOL Sosin">Στρ<supplied reason="lost">άβων</supplied></rdg><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2||ed||στρ[ατηλάτης]=J. Cowey, ZPE 123 (1999) 321-323|<:στρ[ατιώτης]|reg|στυ̣ρ[ατιώτης]:>=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|Συ̣ρ[ίων]=Original Edition:>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="J. Cowey, ZPE 123 (1999) 321-323">στρ<supplied reason="lost">ατηλάτης</supplied></rdg><rdg resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)"><choice><reg>στρ<supplied reason="lost">ατιώτης</supplied></reg><orig>στ<unclear>υ</unclear>ρ<supplied reason="lost">ατιώτης</supplied></orig></choice></rdg><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2||ed||<:στρ[ατηλάτης]|alt|στρ[ιππερς]:>=J. Cowey, ZPE 123 (1999) 321-323|<:στρ[ατιώτης]|reg|στυ̣ρ[ατιώτης]:>=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|Συ̣ρ[ίων]=Original Edition:>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg resp="J. Cowey, ZPE 123 (1999) 321-323"><app type="alternative"><lem>στρ<supplied reason="lost">ατηλάτης</supplied></lem><rdg>στρ<supplied reason="lost">ιππερς</supplied></rdg></app></rdg><rdg resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)"><choice><reg>στρ<supplied reason="lost">ατιώτης</supplied></reg><orig>στ<unclear>υ</unclear>ρ<supplied reason="lost">ατιώτης</supplied></orig></choice></rdg><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=BL 12.2||ed||<:στρ[ατηλάτης]|alt|στρ[ιππερς]:>(?)=J. Cowey, ZPE 123 (1999) 321-323|<:στρ[ατιώτης]|reg|στυ̣ρ[ατιώτης]:>(?)=BL 10.5 (R. Ast, CdE 100 (2020) 13-15)|Συ̣ρ[ίων](?)=Original Edition:>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg resp="J. Cowey, ZPE 123 (1999) 321-323"><app type="alternative"><lem>στρ<supplied reason="lost">ατηλάτης</supplied></lem><rdg>στρ<supplied reason="lost">ιππερς</supplied></rdg></app><certainty match=".." locus="value"/></rdg><rdg resp="BL 10.5 (R. Ast, CdE 100 (2020) 13-15)"><choice><reg>στρ<supplied reason="lost">ατιώτης</supplied></reg><orig>στ<unclear>υ</unclear>ρ<supplied reason="lost">ατιώτης</supplied></orig></choice><certainty match=".." locus="value"/></rdg><rdg resp="Original Edition">Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    #
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=BL 12.2|ed|Συ̣ρ[ίων](?):>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=BL 12.2|ed|Συ̣ρ[ίων](?):>', '<app type="editorial"><lem resp="BL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]=SoSOL 12.2|ed|Συ̣ρ[ίων](?):>', '<app type="editorial"><lem resp="SoSOL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)=SoSOL 12.2|ed|Συ̣ρ[ίων](?):>', '<app type="editorial"><lem resp="SoSOL 12.2">στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς]|ed|Συ̣ρ[ίων](?):>', '<app type="editorial"><lem>στρ<supplied reason="lost">ατηγὸς</supplied></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    assert_equal_fragment_transform '<:στρ[ατηγὸς](?)|ed|Συ̣ρ[ίων](?):>', '<app type="editorial"><lem>στρ<supplied reason="lost">ατηγὸς</supplied><certainty match=".." locus="value"/></lem><rdg>Σ<unclear>υ</unclear>ρ<supplied reason="lost">ίων</supplied><certainty match=".." locus="value"/></rdg></app>'
    #
    assert_equal_fragment_transform '<:a=BL 1.215|ed|b:>', '<app type="editorial"><lem resp="BL 1.215">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:a=SoSOL 1.215|ed|b:>', '<app type="editorial"><lem resp="SoSOL 1.215">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:a=J. Cowey, ZPE 123 (1999) 321-323|ed|b:>', '<app type="editorial"><lem resp="J. Cowey, ZPE 123 (1999) 321-323">a</lem><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:a=BL 1.215|ed|:>', '<app type="editorial"><lem resp="BL 1.215">a</lem><rdg/></app>'
    assert_equal_fragment_transform '<:a=BL 1.215|ed|=Original Editor:>', '<app type="editorial"><lem resp="BL 1.215">a</lem><rdg resp="Original Editor"/></app>'
    assert_equal_fragment_transform '<:=BL 1.215|ed|b:>', '<app type="editorial"><lem resp="BL 1.215"/><rdg>b</rdg></app>'
    assert_equal_fragment_transform '<:|ed|b:>', '<app type="editorial"><lem/><rdg>b</rdg></app>'
  end
    
  def test_glyph
    assert_equal_fragment_transform '*stauros*', '<g type="stauros"/>'
    assert_equal_fragment_transform '*stauros,♱*', '<g type="stauros">♱</g>'
    assert_equal_fragment_transform '*stauros?,♱*', '<unclear><g type="stauros">♱</g></unclear>'
    assert_equal_fragment_transform '*stauros?,♱̣*', '<unclear><g type="stauros"><unclear>♱</unclear></g></unclear>'
    assert_equal_fragment_transform '*stauros,♱̣*', '<g type="stauros"><unclear>♱</unclear></g>'
    assert_equal_fragment_transform '*filler(extension)*', '<g rend="extension" type="filler"/>'
    assert_equal_fragment_transform '*mid-punctus*', '<g type="mid-punctus"/>'
    assert_equal_fragment_transform '*mid-punctus?*', '<unclear><g type="mid-punctus"/></unclear>'
    assert_equal_fragment_transform '*filler(extension)?*', '<unclear><g rend="extension" type="filler"/></unclear>'
  end
  
  def test_hand_shift
    assert_equal_fragment_transform '$m2(?) ', '<handShift new="m2" cert="low"/>'
    assert_equal_fragment_transform '$m22(?) ', '<handShift new="m22" cert="low"/>'
    assert_equal_fragment_transform '$m2b(?) ', '<handShift new="m2b" cert="low"/>'
    assert_equal_fragment_transform '[$m5(?)  ]', '<supplied reason="lost"><handShift new="m5" cert="low"/> </supplied>'
    assert_equal_fragment_transform '$m1 ', '<handShift new="m1"/>'
    assert_equal_fragment_transform '$m20 ', '<handShift new="m20"/>' 
    assert_equal_fragment_transform '$m1a ', '<handShift new="m1a"/>' 
    assert_equal_fragment_transform '[$m5  ]', '<supplied reason="lost"><handShift new="m5"/> </supplied>'
  end
  
  def test_add_place_marginal
    assert_equal_fragment_transform '<|ν|>', '<add rend="sling" place="margin">ν</add>'
    assert_equal_fragment_transform '<|.1|>', '<add rend="sling" place="margin"><gap reason="illegible" quantity="1" unit="character"/></add>'
  end
  
  def test_space
    assert_equal_fragment_transform 'vac.?', '<space extent="unknown" unit="character"/>'
    assert_equal_fragment_transform 'vac.?(?) ', '<space extent="unknown" unit="character"><certainty match=".." locus="name"/></space>'
    assert_equal_fragment_transform 'vac.3', '<space quantity="3" unit="character"/>'
    assert_equal_fragment_transform 'vac.3(?) ', '<space quantity="3" unit="character"><certainty match=".." locus="name"/></space>'
    assert_equal_fragment_transform 'vac.2-5', '<space atLeast="2" atMost="5" unit="character"/>'
    assert_equal_fragment_transform 'vac.2-5(?) ', '<space atLeast="2" atMost="5" unit="character"><certainty match=".." locus="name"/></space>'
    assert_equal_fragment_transform 'vac.ca.3', '<space quantity="3" unit="character" precision="low"/>'
    assert_equal_fragment_transform 'vac.ca.3(?) ', '<space quantity="3" unit="character" precision="low"><certainty match=".." locus="name"/></space>'
    assert_equal_fragment_transform 'vac.?lin', '<space extent="unknown" unit="line"/>'
    assert_equal_fragment_transform 'vac.?lin(?) ', '<space extent="unknown" unit="line"><certainty match=".." locus="name"/></space>'
    assert_equal_fragment_transform 'vac.3lin', '<space quantity="3" unit="line"/>'
    assert_equal_fragment_transform 'vac.3lin(?) ', '<space quantity="3" unit="line"><certainty match=".." locus="name"/></space>'
    assert_equal_fragment_transform 'vac.2-5lin', '<space atLeast="2" atMost="5" unit="line"/>'
    assert_equal_fragment_transform 'vac.2-5lin(?) ', '<space atLeast="2" atMost="5" unit="line"><certainty match=".." locus="name"/></space>'
    assert_equal_fragment_transform 'vac.ca.3lin', '<space quantity="3" unit="line" precision="low"/>'
    assert_equal_fragment_transform 'vac.ca.3lin(?) ', '<space quantity="3" unit="line" precision="low"><certainty match=".." locus="name"/></space>'
  end
    
  def test_supplied_lost_space
    assert_equal_fragment_transform '[vac.? .4-5]', '<supplied reason="lost"><space extent="unknown" unit="character"/> <gap reason="illegible" atLeast="4" atMost="5" unit="character"/></supplied>'  #worked with ANYMULT tweak
    assert_equal_fragment_transform '[vac.?(?)  .4-5]', '<supplied reason="lost"><space extent="unknown" unit="character"><certainty match=".." locus="name"/></space> <gap reason="illegible" atLeast="4" atMost="5" unit="character"/></supplied>'
    assert_equal_fragment_transform '[εὶρ .2 vac.?]', '<supplied reason="lost">εὶρ <gap reason="illegible" quantity="2" unit="character"/> <space extent="unknown" unit="character"/></supplied>'  #worked with ANYMULT tweak
    assert_equal_fragment_transform '[εὶρ .2 vac.?(?) ]', '<supplied reason="lost">εὶρ <gap reason="illegible" quantity="2" unit="character"/> <space extent="unknown" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[ροι. vac.?]', '<supplied reason="lost">ροι. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ς. vac.?]', '<supplied reason="lost">ς. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ρίδος. vac.?]', '<supplied reason="lost">ρίδος. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ρίδος. vac.?(?) ]', '<supplied reason="lost">ρίδος. <space extent="unknown" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[εἰδυίας. vac.?]', '<supplied reason="lost">εἰδυίας. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ομοῦ αὐτῆς vac.?]', '<supplied reason="lost">ομοῦ αὐτῆς <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ομοῦ αὐτῆς vac.?(?) ]', '<supplied reason="lost">ομοῦ αὐτῆς <space extent="unknown" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[ωκα. vac.?]', '<supplied reason="lost">ωκα. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[θαι vac.?]', '<supplied reason="lost">θαι <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[θαι vac.? εὶρ]', '<supplied reason="lost">θαι <space extent="unknown" unit="character"/> εὶρ</supplied>'
    assert_equal_fragment_transform '[θαι vac.?(?)  εὶρ]', '<supplied reason="lost">θαι <space extent="unknown" unit="character"><certainty match=".." locus="name"/></space> εὶρ</supplied>'
    assert_equal_fragment_transform '[vac.?]', '<supplied reason="lost"><space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[vac.?(?) ]', '<supplied reason="lost"><space extent="unknown" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.3]', '<supplied reason="lost"><space quantity="3" unit="character"/></supplied>'
    assert_equal_fragment_transform '[vac.3(?) ]', '<supplied reason="lost"><space quantity="3" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.2-5]', '<supplied reason="lost"><space atLeast="2" atMost="5" unit="character"/></supplied>'
    assert_equal_fragment_transform '[vac.2-5(?) ]', '<supplied reason="lost"><space atLeast="2" atMost="5" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.ca.3]', '<supplied reason="lost"><space quantity="3" unit="character" precision="low"/></supplied>'
    assert_equal_fragment_transform '[vac.ca.3(?) ]', '<supplied reason="lost"><space quantity="3" unit="character" precision="low"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.?lin]', '<supplied reason="lost"><space extent="unknown" unit="line"/></supplied>'
    assert_equal_fragment_transform '[vac.?lin(?) ]', '<supplied reason="lost"><space extent="unknown" unit="line"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.3lin]', '<supplied reason="lost"><space quantity="3" unit="line"/></supplied>'
    assert_equal_fragment_transform '[vac.3lin(?) ]', '<supplied reason="lost"><space quantity="3" unit="line"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.2-5lin]', '<supplied reason="lost"><space atLeast="2" atMost="5" unit="line"/></supplied>'
    assert_equal_fragment_transform '[vac.2-5lin(?) ]', '<supplied reason="lost"><space atLeast="2" atMost="5" unit="line"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.ca.3lin]', '<supplied reason="lost"><space quantity="3" unit="line" precision="low"/></supplied>'
    assert_equal_fragment_transform '[vac.ca.3lin(?) ]', '<supplied reason="lost"><space quantity="3" unit="line" precision="low"><certainty match=".." locus="name"/></space></supplied>'
    #dup above with cert low on supplied
    assert_equal_fragment_transform '[vac.? .4-5(?)]', '<supplied reason="lost" cert="low"><space extent="unknown" unit="character"/> <gap reason="illegible" atLeast="4" atMost="5" unit="character"/></supplied>'  #worked with ANYMULT tweak
    assert_equal_fragment_transform '[vac.?(?)  .4-5(?)]', '<supplied reason="lost" cert="low"><space extent="unknown" unit="character"><certainty match=".." locus="name"/></space> <gap reason="illegible" atLeast="4" atMost="5" unit="character"/></supplied>'
    assert_equal_fragment_transform '[εὶρ .2 vac.?(?)]', '<supplied reason="lost" cert="low">εὶρ <gap reason="illegible" quantity="2" unit="character"/> <space extent="unknown" unit="character"/></supplied>'  #worked with ANYMULT tweak
    assert_equal_fragment_transform '[εὶρ .2 vac.?(?) (?)]', '<supplied reason="lost" cert="low">εὶρ <gap reason="illegible" quantity="2" unit="character"/> <space extent="unknown" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[ροι. vac.?(?)]', '<supplied reason="lost" cert="low">ροι. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ς. vac.?(?)]', '<supplied reason="lost" cert="low">ς. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ρίδος. vac.?(?)]', '<supplied reason="lost" cert="low">ρίδος. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ρίδος. vac.?(?) (?)]', '<supplied reason="lost" cert="low">ρίδος. <space extent="unknown" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[εἰδυίας. vac.?(?)]', '<supplied reason="lost" cert="low">εἰδυίας. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ομοῦ αὐτῆς vac.?(?)]', '<supplied reason="lost" cert="low">ομοῦ αὐτῆς <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[ομοῦ αὐτῆς vac.?(?) (?)]', '<supplied reason="lost" cert="low">ομοῦ αὐτῆς <space extent="unknown" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[ωκα. vac.?(?)]', '<supplied reason="lost" cert="low">ωκα. <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[θαι vac.?(?)]', '<supplied reason="lost" cert="low">θαι <space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[θαι vac.? εὶρ(?)]', '<supplied reason="lost" cert="low">θαι <space extent="unknown" unit="character"/> εὶρ</supplied>'
    assert_equal_fragment_transform '[θαι vac.?(?)  εὶρ(?)]', '<supplied reason="lost" cert="low">θαι <space extent="unknown" unit="character"><certainty match=".." locus="name"/></space> εὶρ</supplied>'
    assert_equal_fragment_transform '[vac.?(?)]', '<supplied reason="lost" cert="low"><space extent="unknown" unit="character"/></supplied>'
    assert_equal_fragment_transform '[vac.?(?) (?)]', '<supplied reason="lost" cert="low"><space extent="unknown" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.3(?)]', '<supplied reason="lost" cert="low"><space quantity="3" unit="character"/></supplied>'
    assert_equal_fragment_transform '[vac.3(?) (?)]', '<supplied reason="lost" cert="low"><space quantity="3" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.2-5(?)]', '<supplied reason="lost" cert="low"><space atLeast="2" atMost="5" unit="character"/></supplied>'
    assert_equal_fragment_transform '[vac.2-5(?) (?)]', '<supplied reason="lost" cert="low"><space atLeast="2" atMost="5" unit="character"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.ca.3(?)]', '<supplied reason="lost" cert="low"><space quantity="3" unit="character" precision="low"/></supplied>'
    assert_equal_fragment_transform '[vac.ca.3(?) (?)]', '<supplied reason="lost" cert="low"><space quantity="3" unit="character" precision="low"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.?lin(?)]', '<supplied reason="lost" cert="low"><space extent="unknown" unit="line"/></supplied>'
    assert_equal_fragment_transform '[vac.?lin(?) (?)]', '<supplied reason="lost" cert="low"><space extent="unknown" unit="line"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.3lin(?)]', '<supplied reason="lost" cert="low"><space quantity="3" unit="line"/></supplied>'
    assert_equal_fragment_transform '[vac.3lin(?) (?)]', '<supplied reason="lost" cert="low"><space quantity="3" unit="line"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.2-5lin(?)]', '<supplied reason="lost" cert="low"><space atLeast="2" atMost="5" unit="line"/></supplied>'
    assert_equal_fragment_transform '[vac.2-5lin(?) (?)]', '<supplied reason="lost" cert="low"><space atLeast="2" atMost="5" unit="line"><certainty match=".." locus="name"/></space></supplied>'
    assert_equal_fragment_transform '[vac.ca.3lin(?)]', '<supplied reason="lost" cert="low"><space quantity="3" unit="line" precision="low"/></supplied>'
    assert_equal_fragment_transform '[vac.ca.3lin(?) (?)]', '<supplied reason="lost" cert="low"><space quantity="3" unit="line" precision="low"><certainty match=".." locus="name"/></space></supplied>'
  end
    
  def test_del_rend
    assert_equal_fragment_transform 'a〚bc〛', 'a<del rend="erasure">bc</del>'
    assert_equal_fragment_transform 'ab〚c def g〛hi', 'ab<del rend="erasure">c def g</del>hi'
    assert_equal_fragment_transform '〚abcdefg〛', '<del rend="erasure">abcdefg</del>'
    assert_equal_fragment_transform '〚Xabcdefg〛', '<del rend="cross-strokes">abcdefg</del>'
    assert_equal_fragment_transform '〚/abcdefg〛', '<del rend="slashes">abcdefg</del>'
    assert_equal_fragment_transform '〚 Ἀκῆς 〛', '<del rend="erasure"> Ἀκῆς </del>'
    assert_equal_fragment_transform '〚(|Ψε̣.2λως|) 〛', '<del rend="erasure"><abbr>Ψ<unclear>ε</unclear><gap reason="illegible" quantity="2" unit="character"/>λως</abbr> </del>'
    assert_equal_fragment_transform '〚X Ἀκῆς 〛', '<del rend="cross-strokes"> Ἀκῆς </del>'
    assert_equal_fragment_transform '〚X(|Ψε̣.2λως|) 〛', '<del rend="cross-strokes"><abbr>Ψ<unclear>ε</unclear><gap reason="illegible" quantity="2" unit="character"/>λως</abbr> </del>'
    assert_equal_fragment_transform '〚/ Ἀκῆς 〛', '<del rend="slashes"> Ἀκῆς </del>'
    assert_equal_fragment_transform '〚/(|Ψε̣.2λως|) 〛', '<del rend="slashes"><abbr>Ψ<unclear>ε</unclear><gap reason="illegible" quantity="2" unit="character"/>λως</abbr> </del>'
    assert_equal_fragment_transform '〚 Ἀκῆς (?)〛', '<del rend="erasure"> Ἀκῆς <certainty match=".." locus="value"/></del>'
    assert_equal_fragment_transform '〚(|Ψε̣.2λως|) (?)〛', '<del rend="erasure"><abbr>Ψ<unclear>ε</unclear><gap reason="illegible" quantity="2" unit="character"/>λως</abbr> <certainty match=".." locus="value"/></del>'
    assert_equal_fragment_transform '〚X Ἀκῆς (?)〛', '<del rend="cross-strokes"> Ἀκῆς <certainty match=".." locus="value"/></del>'
    assert_equal_fragment_transform '〚X(|Ψε̣.2λως|) (?)〛', '<del rend="cross-strokes"><abbr>Ψ<unclear>ε</unclear><gap reason="illegible" quantity="2" unit="character"/>λως</abbr> <certainty match=".." locus="value"/></del>'
    assert_equal_fragment_transform '〚/ Ἀκῆς (?)〛', '<del rend="slashes"> Ἀκῆς <certainty match=".." locus="value"/></del>'
    assert_equal_fragment_transform '〚/(|Ψε̣.2λως|) (?)〛', '<del rend="slashes"><abbr>Ψ<unclear>ε</unclear><gap reason="illegible" quantity="2" unit="character"/>λως</abbr> <certainty match=".." locus="value"/></del>'
  end
    
  def test_note
    assert_equal_fragment_transform '/*abcdefg*/', '<note xml:lang="en">abcdefg</note>'
    assert_equal_fragment_transform '/*?*/', '<note xml:lang="en">?</note>'
    assert_equal_fragment_transform '/*m2?*/', '<note xml:lang="en">m2?</note>'
    assert_equal_fragment_transform '/*text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4*/', '<note xml:lang="en">text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4</note>'
    assert_equal_fragment_transform '~|di ẹ[mu]|~la ', '<foreign xml:lang="la">di <unclear>e</unclear><supplied reason="lost">mu</supplied></foreign>'
    assert_equal_fragment_transform '/*abcdefg(ref=p.stras;9;842=PStras 9,842)*/', '<note xml:lang="en">abcdefg<ref n="p.stras;9;842" type="reprint-in">PStras 9,842</ref></note>'
    assert_equal_fragment_transform '/*?(ref=chr.wilck;;474=WChr 474)*/', '<note xml:lang="en">?<ref n="chr.wilck;;474" type="reprint-in">WChr 474</ref></note>'
    assert_equal_fragment_transform '/*m2?(ref=sb;18;13856=SB 18,13856)*/', '<note xml:lang="en">m2?<ref n="sb;18;13856" type="reprint-in">SB 18,13856</ref></note>'
    assert_equal_fragment_transform '/*text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4(ref=p.mich;1;12=PMich 1,12)*/', '<note xml:lang="en">text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4<ref n="p.mich;1;12" type="reprint-in">PMich 1,12</ref></note>'
    assert_equal_fragment_transform '/*PLips 33,v reprinted in (ref=chr.mitt;;55=MChr 55)*/', '<note xml:lang="en">PLips 33,v reprinted in <ref n="chr.mitt;;55" type="reprint-in">MChr 55</ref></note>'
    assert_equal_fragment_transform '/*POxy 7,1047,minf reprinted in (ref=sb;18;13856=SB 18,13856)*/', '<note xml:lang="en">POxy 7,1047,minf reprinted in <ref n="sb;18;13856" type="reprint-in">SB 18,13856</ref></note>'
    assert_equal_fragment_transform '/*POxy 12,1578,v reprinted in (ref=p.oxy;14;1736=POxy 14,1736)*/', '<note xml:lang="en">POxy 12,1578,v reprinted in <ref n="p.oxy;14;1736" type="reprint-in">POxy 14,1736</ref></note>'
    assert_equal_fragment_transform '/*POxy 1,43,v reprinted in (ref=chr.wilck;;474=WChr 474)*/', '<note xml:lang="en">POxy 1,43,v reprinted in <ref n="chr.wilck;;474" type="reprint-in">WChr 474</ref></note>'
    assert_equal_fragment_transform '/*POxy 1,71,v reprinted in (ref=p.lond;3;755=PLond 3,755)*/', '<note xml:lang="en">POxy 1,71,v reprinted in <ref n="p.lond;3;755" type="reprint-in">PLond 3,755</ref></note>'
    assert_equal_fragment_transform '/*PVindobWorp 8,r reprinted in (ref=xxx=CPR 17A,7)*/', '<note xml:lang="en">PVindobWorp 8,r reprinted in <ref n="xxx" type="reprint-in">CPR 17A,7</ref></note>'
    assert_equal_fragment_transform '/*PVindobWorp 8,v reprinted in (ref=xxx=PCharite 13)*/', '<note xml:lang="en">PVindobWorp 8,v reprinted in <ref n="xxx" type="reprint-in">PCharite 13</ref></note>'
    assert_equal_fragment_transform '/*PStras 1,71,r reprinted in (ref=p.stras;9;842=PStras 9,842)*/', '<note xml:lang="en">PStras 1,71,r reprinted in <ref n="p.stras;9;842" type="reprint-in">PStras 9,842</ref></note>'
    assert_equal_fragment_transform '/*PSI 4,409,B reprinted in (ref=p.mich;1;12=PMich 1,12)*/', '<note xml:lang="en">PSI 4,409,B reprinted in <ref n="p.mich;1;12" type="reprint-in">PMich 1,12</ref></note>'
  end
  
  def test_p5_supraline_underline
    assert_equal_fragment_transform '¯_ [.?] .1ηρου_¯', '<hi rend="supraline-underline"> <gap reason="lost" extent="unknown" unit="character"/> <gap reason="illegible" quantity="1" unit="character"/>ηρου</hi>'
    assert_equal_fragment_transform '¯_words sic_¯', '<hi rend="supraline-underline">words sic</hi>'
    assert_equal_fragment_transform '[Ἁρχῦψις] ¯_[Πετεή]σιος_¯ αγδ  ¯_δεξβεφξβν_¯ ςεφξνςφη', '<supplied reason="lost">Ἁρχῦψις</supplied> <hi rend="supraline-underline"><supplied reason="lost">Πετεή</supplied>σιος</hi> αγδ  <hi rend="supraline-underline">δεξβεφξβν</hi> ςεφξνςφη'
  end
  
  def test_tall
    assert_equal_fragment_transform '~||Ἑρεννίαν Γέμελλαν||~tall', '<hi rend="tall">Ἑρεννίαν Γέμελλαν</hi>'
    assert_equal_fragment_transform '~||x||~tall', '<hi rend="tall">x</hi>'
    assert_equal_fragment_transform '~|| ο(´ ῾)||~tall', '<hi rend="tall"><hi rend="acute"><hi rend="asper">ο</hi></hi></hi>'
    assert_equal_fragment_transform '[Ἁρχῦψις] ~||[Πετεή]σιος||~tall αγδ  ~||δεξβεφξβν||~tall ςεφξνςφη', '<supplied reason="lost">Ἁρχῦψις</supplied> <hi rend="tall"><supplied reason="lost">Πετεή</supplied>σιος</hi> αγδ  <hi rend="tall">δεξβεφξβν</hi> ςεφξνςφη'
  end

  def test_subscript
    assert_equal_fragment_transform '\\|(χρυσοχο ϊ(¨)κ(ῷ))|/', '<hi rend="subscript"><expan>χρυσοχο<hi rend="diaeresis">ϊ</hi>κ<ex>ῷ</ex></expan></hi>'
    assert_equal_fragment_transform '\\|(χρυσοχο ϊ(¨)κ(ῷ))(?)|/', '<hi rend="subscript"><expan>χρυσοχο<hi rend="diaeresis">ϊ</hi>κ<ex>ῷ</ex></expan><certainty match=".." locus="value"/></hi>'
    assert_equal_fragment_transform '\\|η|/', '<hi rend="subscript">η</hi>'
    assert_equal_fragment_transform '\\|η(?)|/', '<hi rend="subscript">η<certainty match=".." locus="value"/></hi>'
  end
  
  def test_supraline
    assert_equal_fragment_transform '[Ἁρχῦψις] ¯[Πετεή]σιος¯ αγδ  δ̄ε̄ξ̄β̄ε̄φ̄ξ̄β̄ν̄ ςεφξνςφη', '<supplied reason="lost">Ἁρχῦψις</supplied> <hi rend="supraline"><supplied reason="lost">Πετεή</supplied>σιος</hi> αγδ  <hi rend="supraline">δεξβεφξβν</hi> ςεφξνςφη'
    assert_equal_fragment_transform 'w̄ōr̄d̄s̄ ̄s̄īc̄', '<hi rend="supraline">words sic</hi>'
    assert_equal_fragment_transform 'w̄ōr̄d̄', '<hi rend="supraline">word</hi>'
    assert_equal_fragment_transform 'w̄ōκ̣̄r̄d̄', '<hi rend="supraline">wo<unclear>κ</unclear>rd</hi>'
    assert_equal_fragment_transform 'w̄κ̣̄ōκ̣̄r̄κ̣̄d̄', '<hi rend="supraline">w<unclear>κ</unclear>o<unclear>κ</unclear>r<unclear>κ</unclear>d</hi>'
    assert_equal_fragment_transform '¯.1¯', '<hi rend="supraline"><gap reason="illegible" quantity="1" unit="character"/></hi>'
    assert_equal_fragment_transform '¯.22¯', '<hi rend="supraline"><gap reason="illegible" quantity="22" unit="character"/></hi>'
    assert_equal_fragment_transform '¯.333¯', '<hi rend="supraline"><gap reason="illegible" quantity="333" unit="character"/></hi>'
    assert_equal_fragment_transform '¯James drinks 1̄3̄ beers¯', '<hi rend="supraline">James drinks <hi rend="supraline">13</hi> beers</hi>'
    assert_equal_fragment_transform '¯vestig ¯', '<hi rend="supraline"><gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></hi>'
    assert_equal_fragment_transform '¯<#α=1#>¯', '<hi rend="supraline"><num value="1">α</num></hi>'
    assert_equal_fragment_transform '¯<#β=2#>¯', '<hi rend="supraline"><num value="2">β</num></hi>'
    assert_equal_fragment_transform '¯<#γ=3#>¯', '<hi rend="supraline"><num value="3">γ</num></hi>'
    assert_equal_fragment_transform '<#ᾱ=1#>', '<num value="1"><hi rend="supraline">α</hi></num>'
    assert_equal_fragment_transform '<#β̄=2#>', '<num value="2"><hi rend="supraline">β</hi></num>'
    assert_equal_fragment_transform '<#γ̄=3#>', '<num value="3"><hi rend="supraline">γ</hi></num>'
    assert_equal_fragment_transform '<#ῑ=10#>', '<num value="10"><hi rend="supraline">ι</hi></num>'
    assert_equal_fragment_transform '<#ῑη̄=18#>', '<num value="18"><hi rend="supraline">ιη</hi></num>'
    assert_equal_fragment_transform '<#𐅵̄=1/2#>', '<num value="1/2"><hi rend="supraline">𐅵</hi></num>'
    assert_equal_fragment_transform '<#𐅸̄=3/4#>', '<num value="3/4"><hi rend="supraline">𐅸</hi></num>'
    assert_equal_fragment_transform '<#ῑβ̄=1/12#>', '<num value="1/12"><hi rend="supraline">ιβ</hi></num>'
    assert_equal_fragment_transform '<#[ι]ᾱ=11#>', '<num value="11"><supplied reason="lost">ι</supplied><hi rend="supraline">α</hi></num>'
    assert_equal_fragment_transform '<#¯[ι]α¯=11#>', '<num value="11"><hi rend="supraline"><supplied reason="lost">ι</supplied>α</hi></num>'
#=begin
    assert_equal_fragment_transform '34. [Ἁρχῦψις] Πετεήσιος <#α=1#> ((ἔτους)) ἀπὸ ¯<#ϛ=6#> <#ŵ=1/2#> <#η \'=1/8#>¯((ἀρτάβαι)) ¯<#λα=31#>¯<#α=1#> <#δ \'=1/4#> <#η \'=1/8#> ((ἀρτάβαι)) <#δ=4#> <#ŵ=1/2#>, καὶ (με(μερισμένον)) ἀπὸ τῆς ((προτερον)) 

    413. ¯<#α=1#>¯ ((ἄρουραι)) <#ρλγ=133#> <#ŵ=1/2#> <#δ \'=1/4#> 

    414. ¯<#β=2#>¯   <:<#1\32 <#δ \'=1/4#>/=#>|subst|<#ρ〚μβ〛=142#>〚 <#δ \'=1/4#>〛:> ((ἀρτάβαι)) [.?] 

    415. ¯<#γ=3#>¯         <#ρνθ=159#> <#δ \'=1/4#> [.?] 

    416. <#ριε=115#> <#ŵ=1/2#> [((ἀρτάβαι))] .2[.?]', '<lb n="34"/><supplied reason="lost">Ἁρχῦψις</supplied> Πετεήσιος <num value="1">α</num> <expan><ex>ἔτους</ex></expan> ἀπὸ <hi rend="supraline"><num value="6">ϛ</num> <num value="1/2">ŵ</num> <num value="1/8" rend="tick">η</num></hi><expan><ex>ἀρτάβαι</ex></expan> <hi rend="supraline"><num value="31">λα</num></hi><num value="1">α</num> <num value="1/4" rend="tick">δ</num> <num value="1/8" rend="tick">η</num> <expan><ex>ἀρτάβαι</ex></expan> <num value="4">δ</num> <num value="1/2">ŵ</num>, καὶ <expan>με<ex>μερισμένον</ex></expan> ἀπὸ τῆς <expan><ex>προτερον</ex></expan> 

    <lb n="413"/><hi rend="supraline"><num value="1">α</num></hi> <expan><ex>ἄρουραι</ex></expan> <num value="133">ρλγ</num> <num value="1/2">ŵ</num> <num value="1/4" rend="tick">δ</num> 

    <lb n="414"/><hi rend="supraline"><num value="2">β</num></hi>   <subst><add place="inline"><num>1<add place="above">32 <num value="1/4" rend="tick">δ</num></add></num></add><del rend="corrected"><num value="142">ρ<del rend="erasure">μβ</del></num><del rend="erasure"> <num value="1/4" rend="tick">δ</num></del></del></subst> <expan><ex>ἀρτάβαι</ex></expan> <gap reason="lost" extent="unknown" unit="character"/> 

    <lb n="415"/><hi rend="supraline"><num value="3">γ</num></hi>         <num value="159">ρνθ</num> <num value="1/4" rend="tick">δ</num> <gap reason="lost" extent="unknown" unit="character"/> 

    <lb n="416"/><num value="115">ριε</num> <num value="1/2">ŵ</num> <supplied reason="lost"><expan><ex>ἀρτάβαι</ex></expan></supplied> <gap reason="illegible" quantity="2" unit="character"/><gap reason="lost" extent="unknown" unit="character"/>'
#=end
  end
    
  def test_superscript
    assert_equal_fragment_transform '|^<#ι=10#> ^|', '<hi rend="superscript"><num value="10">ι</num> </hi>'
    assert_equal_fragment_transform '|^<:σημεῖον|corr|σημιον:>^|', '<hi rend="superscript"><choice><corr>σημεῖον</corr><sic>σημιον</sic></choice></hi>'
    assert_equal_fragment_transform '[Ἁρχῦψις] |^[Πετεή]σιος^| αγδ  |^δεξβεφξβν^| ςεφξνςφη', '<supplied reason="lost">Ἁρχῦψις</supplied> <hi rend="superscript"><supplied reason="lost">Πετεή</supplied>σιος</hi> αγδ  <hi rend="superscript">δεξβεφξβν</hi> ςεφξνςφη'
  end
  
  def test_p5_above
    assert_equal_fragment_transform '\\ς/', '<add place="above">ς</add>'
    assert_equal_fragment_transform '\\ς(?)/', '<add place="above">ς<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '\\καὶ̣ Κ̣ε̣ρ̣κεσήφεως/', '<add place="above">κα<unclear>ὶ</unclear> <unclear>Κερ</unclear>κεσήφεως</add>'
    assert_equal_fragment_transform '\\καὶ̣ Κ̣ε̣ρ̣κεσήφεως(?)/', '<add place="above">κα<unclear>ὶ</unclear> <unclear>Κερ</unclear>κεσήφεως<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '\\κα̣ὶ̣ μὴ ὁμολογη〚.1〛/', '<add place="above">κ<unclear>αὶ</unclear> μὴ ὁμολογη<del rend="erasure"><gap reason="illegible" quantity="1" unit="character"/></del></add>'
    assert_equal_fragment_transform '\\κα̣ὶ̣ μὴ ὁμολογη〚.1〛(?)/', '<add place="above">κ<unclear>αὶ</unclear> μὴ ὁμολογη<del rend="erasure"><gap reason="illegible" quantity="1" unit="character"/></del><certainty match=".." locus="name"/></add>'
  end
  
  def test_p5_below
    assert_equal_fragment_transform '//ς\\\\', '<add place="below">ς</add>'
    assert_equal_fragment_transform '//<#δ=4#>\\\\', '<add place="below"><num value="4">δ</num></add>'
    assert_equal_fragment_transform '//ς(?)\\\\', '<add place="below">ς<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '//<#δ=4#>(?)\\\\', '<add place="below"><num value="4">δ</num><certainty match=".." locus="name"/></add>'
  end
    
  def test_add_place_interlinear
    assert_equal_fragment_transform '||interlin: καὶ οὐδ᾽ ἄλλοις ἔχοντες ἐλάσσονος τιμῆς διαθέσθαι εὐχερῶς.||', '<add place="interlinear"> καὶ οὐδ᾽ ἄλλοις ἔχοντες ἐλάσσονος τιμῆς διαθέσθαι εὐχερῶς.</add>'
    assert_equal_fragment_transform '||interlin: ὧ( ῾)ν||', '<add place="interlinear"><hi rend="asper">ὧ</hi>ν</add>'
    assert_equal_fragment_transform '||interlin: ὧ( ῾)ν(?)||', '<add place="interlinear"><hi rend="asper">ὧ</hi>ν<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '||interlin:[φοινίκ]ω̣ν̣ κ̣αὶ ἐ̣λ̣αιῶν||', '<add place="interlinear"><supplied reason="lost">φοινίκ</supplied><unclear>ων</unclear> <unclear>κ</unclear>αὶ <unclear>ἐλ</unclear>αιῶν</add>'
    assert_equal_fragment_transform '||interlin: $m2  (Οὐεναφρ(ίου)) ||', '<add place="interlinear"> <handShift new="m2"/> <expan>Οὐεναφρ<ex>ίου</ex></expan> </add>'
    assert_equal_fragment_transform '||interlin:ε||', '<add place="interlinear">ε</add>'
    assert_equal_fragment_transform '||interlin:Πωλίων ἀπάτωρ||', '<add place="interlinear">Πωλίων ἀπάτωρ</add>'
    assert_equal_fragment_transform '||interlin:Πωλίων ἀπάτωρ(?)||', '<add place="interlinear">Πωλίων ἀπάτωρ<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '||interlin:.1||', '<add place="interlinear"><gap reason="illegible" quantity="1" unit="character"/></add>'
    assert_equal_fragment_transform '||interlin:καὶ (κρι(θῆς)) (ἀρ(τ )) <#β=2#> [.?]< 8. καὶ Πάσιτ̣[ι .?] 9. ||interlin:καὶ (κρι(θῆς)) (ἀρ(τ )) <#β=2#> [.?]|| 10. καὶ Τεΰ̣ρ̣ει .3[.?] 11. > καὶ (κρι(θῆς)) (ἀρ(τ )) <#β=2#> [.?]||', '<add place="interlinear">καὶ <expan>κρι<ex>θῆς</ex></expan> <expan>ἀρ<ex>τ </ex></expan> <num value="2">β</num> <gap reason="lost" extent="unknown" unit="character"/><supplied reason="omitted"> <lb n="8"/>καὶ Πάσι<unclear>τ</unclear><supplied reason="lost">ι <gap reason="illegible" extent="unknown" unit="character"/></supplied> <lb n="9"/><add place="interlinear">καὶ <expan>κρι<ex>θῆς</ex></expan> <expan>ἀρ<ex>τ </ex></expan> <num value="2">β</num> <gap reason="lost" extent="unknown" unit="character"/></add> <lb n="10"/>καὶ Τε<unclear>ΰρ</unclear>ει <gap reason="illegible" quantity="3" unit="character"/><gap reason="lost" extent="unknown" unit="character"/> <lb n="11"/></supplied> καὶ <expan>κρι<ex>θῆς</ex></expan> <expan>ἀρ<ex>τ </ex></expan> <num value="2">β</num> <gap reason="lost" extent="unknown" unit="character"/></add>'
    assert_equal_fragment_transform '<||interlin: καὶ οὐδ᾽ ἄλλοις ἔχοντες ἐλάσσονος τιμῆς διαθέσθαι εὐχερῶς.||>', '<supplied reason="omitted"><add place="interlinear"> καὶ οὐδ᾽ ἄλλοις ἔχοντες ἐλάσσονος τιμῆς διαθέσθαι εὐχερῶς.</add></supplied>'
    assert_equal_fragment_transform '||interlin: ὧ( ῾)ν||interlin: ὧ( ῾)ν||||', '<add place="interlinear"><hi rend="asper">ὧ</hi>ν<add place="interlinear"><hi rend="asper">ὧ</hi>ν</add></add>'
  end
  
  def test_add_place_margin_underline
    assert_equal_fragment_transform '<_ν_>', '<add rend="underline" place="margin">ν</add>'
    assert_equal_fragment_transform '<_.1_>', '<add rend="underline" place="margin"><gap reason="illegible" quantity="1" unit="character"/></add>'
    assert_equal_fragment_transform '<_ν(?)_>', '<add rend="underline" place="margin">ν<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '<_.1(?)_>', '<add rend="underline" place="margin"><gap reason="illegible" quantity="1" unit="character"/><certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '<|ν|>', '<add rend="sling" place="margin">ν</add>'
    assert_equal_fragment_transform '<|.1|>', '<add rend="sling" place="margin"><gap reason="illegible" quantity="1" unit="character"/></add>'
    assert_equal_fragment_transform '<|ν(?)|>', '<add rend="sling" place="margin">ν<certainty match=".." locus="name"/></add>'
    assert_equal_fragment_transform '<|.1(?)|>', '<add rend="sling" place="margin"><gap reason="illegible" quantity="1" unit="character"/><certainty match=".." locus="name"/></add>'
  end
    
  def test_foreign_lang
    assert_equal_fragment_transform '~|veni vedi vici|~la ', '<foreign xml:lang="la">veni vedi vici</foreign>'
    assert_equal_fragment_transform '~|di\' emu Foibạmṃ[onis]|~la ', '<foreign xml:lang="la">di\' emu Foib<unclear>a</unclear>m<unclear>m</unclear><supplied reason="lost">onis</supplied></foreign>'
    assert_equal_fragment_transform '[ ~|cum obtulisset libellum Eulogii: .? ex officio.|~la  ὁποῖον]', '<supplied reason="lost"> <foreign xml:lang="la">cum obtulisset libellum Eulogii: <gap reason="illegible" extent="unknown" unit="character"/> ex officio.</foreign> ὁποῖον</supplied>'
    assert_equal_fragment_transform '~|legi 
    12. legi |~la ', '<foreign xml:lang="la">legi 
    <lb n="12"/>legi </foreign>'
    assert_equal_fragment_transform '[υσίου Τόπων ~|? .|~la  ὑ]', '<supplied reason="lost">υσίου Τόπων <foreign xml:lang="la">? .</foreign> ὑ</supplied>'
    assert_equal_fragment_transform '[νουμηνίᾳ ~|?,|~la  ἐν τῇ Σοκν]', '<supplied reason="lost">νουμηνίᾳ <foreign xml:lang="la">?,</foreign> ἐν τῇ Σοκν</supplied>'
    assert_equal_fragment_transform '/*abcdefg*/', '<note xml:lang="en">abcdefg</note>'
    assert_equal_fragment_transform '/*?*/', '<note xml:lang="en">?</note>'
    assert_equal_fragment_transform '/*m2?*/', '<note xml:lang="en">m2?</note>'
    assert_equal_fragment_transform '/*text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4*/', '<note xml:lang="en">text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4</note>'
    assert_equal_fragment_transform '~|di ẹ[mu]|~la ', '<foreign xml:lang="la">di <unclear>e</unclear><supplied reason="lost">mu</supplied></foreign>'
    assert_equal_fragment_transform '/*text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4*/', '<note xml:lang="en">text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4</note>'
    assert_equal_fragment_transform '~|? vac.? [ ]|~la ', '<foreign xml:lang="la">? <space extent="unknown" unit="character"/> <supplied reason="lost"> </supplied></foreign>'
    assert_equal_fragment_transform '~|Εὐδυνέου 
    00. πέμπτῃ|~grc ', '<foreign xml:lang="grc">Εὐδυνέου 
    <lb n="00"/>πέμπτῃ</foreign>'
    assert_equal_fragment_transform '~|M e(´)viae Dionusari o(´) e lege Julia |~la ', '<foreign xml:lang="la">M<hi rend="acute">e</hi>viae Dionusari<hi rend="acute">o</hi> e lege Julia </foreign>'
    assert_equal_fragment_transform '~|di emu  i(¨)ustu diakonu eteliothe |~la ', '<foreign xml:lang="la">di emu <hi rend="diaeresis">i</hi>ustu diakonu eteliothe </foreign>'
    assert_equal_fragment_transform '[ ~|cum obtulisset libellum Eulogii: .? ex officio.|~la  ὁποῖον]', '<supplied reason="lost"> <foreign xml:lang="la">cum obtulisset libellum Eulogii: <gap reason="illegible" extent="unknown" unit="character"/> ex officio.</foreign> ὁποῖον</supplied>'
    assert_equal_fragment_transform '~|di\' emu Foibạmṃ[onis]|~la ', '<foreign xml:lang="la">di\' emu Foib<unclear>a</unclear>m<unclear>m</unclear><supplied reason="lost">onis</supplied></foreign>'
    assert_equal_fragment_transform '~|di\' (em(u)) (Iust(u)) (upodiacon(u)) (sumbolai(ografu)) eteliothḥ|~la ', '<foreign xml:lang="la">di\' <expan>em<ex>u</ex></expan> <expan>Iust<ex>u</ex></expan> <expan>upodiacon<ex>u</ex></expan> <expan>sumbolai<ex>ografu</ex></expan> etelioth<unclear>h</unclear></foreign>'
    assert_equal_fragment_transform '~|? [ ]|~la ', '<foreign xml:lang="la">? <supplied reason="lost"> </supplied></foreign>'
    assert_equal_fragment_transform '~|?. [ ]|~la ', '<foreign xml:lang="la">?. <supplied reason="lost"> </supplied></foreign>'
    assert_equal_fragment_transform '18. [.3]ς̣ Ζωΐλου ((ἄρουραι)) <#λ̣β̣=32#> <#𐅵 \'=1/2#> <#ιϛ \'=1/16#> <#λβ \'=1/32#>((δηναρίων
 μυριάδες)) [.?]', '<lb n="18"/><gap reason="lost" quantity="3" unit="character"/><unclear>ς</unclear> Ζωΐλου <expan><ex>ἄρουραι</ex></expan> <num value="32"><unclear>λβ</unclear></num> <num value="1/2" rend="tick">𐅵</num> <num value="1/16" rend="tick">ιϛ</num> <num value="1/32" rend="tick">λβ</num><expan><ex>δηναρίων
 μυριάδες</ex></expan> <gap reason="lost" extent="unknown" unit="character"/>'
    assert_equal_fragment_transform '((δηναρίων μυριάδες))', '<expan><ex>δηναρίων μυριάδες</ex></expan>'
    assert_equal_fragment_transform '((ὀβολοῦ 1/2))', '<expan><ex>ὀβολοῦ 1/2</ex></expan>'
    assert_equal_fragment_transform '~| \$m3 ὁ <:δεῖνα|corr|δινα:>/ $m4 /*?*/ (κα(ὶ)) (κα(ὶ)) \$m3 (χρυ(σοῦ)) (λίτρ(ας)) <#ε=5#>/ $m4 /*?*/ ὑπομνησθήσονται διὰ τῆς τάξεως ἢ τὸ δέον{ι} δίκης ἐκτὸς ἐπιγνῶναι ἢ ἀντιλέγοντες δικάσασθαι 16. ἐν τῷ δικαστηρίῳ. $m2 (Φλά(ουιος)) Ῥωμανὸς υἱὸς Ἰακὼβ (|Φλ|) παραβάλλω Συριανὸν ἀπὸ (πριγκ(ιπαλίων)) εἰς (χρυ(σοῦ)) (λί(τρας)) <:πέντε|corr|πεντη:> <#=5#>.|~grc ', '<foreign xml:lang="grc"> <add place="above"><handShift new="m3"/>ὁ <choice><corr>δεῖνα</corr><sic>δινα</sic></choice></add> <handShift new="m4"/><note xml:lang="en">?</note> <expan>κα<ex>ὶ</ex></expan> <expan>κα<ex>ὶ</ex></expan> <add place="above"><handShift new="m3"/><expan>χρυ<ex>σοῦ</ex></expan> <expan>λίτρ<ex>ας</ex></expan> <num value="5">ε</num></add> <handShift new="m4"/><note xml:lang="en">?</note> ὑπομνησθήσονται διὰ τῆς τάξεως ἢ τὸ δέον<surplus>ι</surplus> δίκης ἐκτὸς ἐπιγνῶναι ἢ ἀντιλέγοντες δικάσασθαι <lb n="16"/>ἐν τῷ δικαστηρίῳ. <handShift new="m2"/><expan>Φλά<ex>ουιος</ex></expan> Ῥωμανὸς υἱὸς Ἰακὼβ <abbr>Φλ</abbr> παραβάλλω Συριανὸν ἀπὸ <expan>πριγκ<ex>ιπαλίων</ex></expan> εἰς <expan>χρυ<ex>σοῦ</ex></expan> <expan>λί<ex>τρας</ex></expan> <choice><corr>πέντε</corr><sic>πεντη</sic></choice> <num value="5"/>.</foreign>'
    assert_equal_fragment_transform '~|εἰ.2η πειθην|~grc ', '<foreign xml:lang="grc">εἰ<gap reason="illegible" quantity="2" unit="character"/>η πειθην</foreign>'
    assert_equal_fragment_transform '~|εἰ?2η πειθην|~grc ', '<foreign xml:lang="grc">εἰ?2η πειθην</foreign>'
    assert_equal_fragment_transform '~|Sen[ec]ion (d(ixit)): καλῶς διδάσκει. αὕτη ἡ οἰκία ἐ̣[γγυς /*?*/ τῆ]ς οἰκίας τοῦ λογιστοῦ ἐστιν. ὁ λογιστὴς ἐκεῖ μένει. 15. (Fl(avius)) Leontius Beronicianus (v(ir)) (c(larissimus)) (pr(aeses)) (Tebaei(dis)) (d(ixit)): |~la ', '<foreign xml:lang="la">Sen<supplied reason="lost">ec</supplied>ion <expan>d<ex>ixit</ex></expan>: καλῶς διδάσκει. αὕτη ἡ οἰκία <unclear>ἐ</unclear><supplied reason="lost">γγυς <note xml:lang="en">?</note> τῆ</supplied>ς οἰκίας τοῦ λογιστοῦ ἐστιν. ὁ λογιστὴς ἐκεῖ μένει. <lb n="15"/><expan>Fl<ex>avius</ex></expan> Leontius Beronicianus <expan>v<ex>ir</ex></expan> <expan>c<ex>larissimus</ex></expan> <expan>pr<ex>aeses</ex></expan> <expan>Tebaei<ex>dis</ex></expan> <expan>d<ex>ixit</ex></expan>: </foreign>'
    assert_equal_fragment_transform '~|et (rec(itavit)): Sergio et |~la ', '<foreign xml:lang="la">et <expan>rec<ex>itavit</ex></expan>: Sergio et </foreign>'
    assert_equal_fragment_transform '(σεσημ(είωμαι)).', '<expan>σεσημ<ex>είωμαι</ex></expan>.'
    assert_equal_fragment_transform '~|[Ac]holius (d(ixit))|~la ', '<foreign xml:lang="la"><supplied reason="lost">Ac</supplied>holius <expan>d<ex>ixit</ex></expan></foreign>'
    assert_equal_fragment_transform '~|Acholius dixit: |~la ', '<foreign xml:lang="la">Acholius dixit: </foreign>'
    assert_equal_fragment_transform '~|[Ac]holius (d(ixit)): |~la ', '<foreign xml:lang="la"><supplied reason="lost">Ac</supplied>holius <expan>d<ex>ixit</ex></expan>: </foreign>'
    assert_equal_fragment_transform '~|totelo (ex(ceptoribus)). |~la ', '<foreign xml:lang="la">totelo <expan>ex<ex>ceptoribus</ex></expan>. </foreign>'
    assert_equal_fragment_transform '~|(co(nsulibus)) die <#iiii=#> ~|(Kal(endas)) Ianuạṛịạṣ Biono|~la .2[.?]~|saṛ|~la [.1].1~|totelo (ex(ceptoribus)). |~la |~la ', '<foreign xml:lang="la"><expan>co<ex>nsulibus</ex></expan> die <num>iiii</num> <foreign xml:lang="la"><expan>Kal<ex>endas</ex></expan> Ianu<unclear>arias</unclear> Biono</foreign><gap reason="illegible" quantity="2" unit="character"/><gap reason="lost" extent="unknown" unit="character"/><foreign xml:lang="la">sa<unclear>r</unclear></foreign><gap reason="lost" quantity="1" unit="character"/><gap reason="illegible" quantity="1" unit="character"/><foreign xml:lang="la">totelo <expan>ex<ex>ceptoribus</ex></expan>. </foreign></foreign>'
    assert_equal_fragment_transform '~|(Fl(avius)) Leontius (Beronicianu(s)) (v(ir)) (c(larissimus)) (pr(aeses)) (Tebaei(dis)) (d(ixit)): |~la ', '<foreign xml:lang="la"><expan>Fl<ex>avius</ex></expan> Leontius <expan>Beronicianu<ex>s</ex></expan> <expan>v<ex>ir</ex></expan> <expan>c<ex>larissimus</ex></expan> <expan>pr<ex>aeses</ex></expan> <expan>Tebaei<ex>dis</ex></expan> <expan>d<ex>ixit</ex></expan>: </foreign>'
    assert_equal_fragment_transform '~|<:et|corr|ec:> (c(etera)): (or(ator)) adiecit: |~la ', '<foreign xml:lang="la"><choice><corr>et</corr><sic>ec</sic></choice> <expan>c<ex>etera</ex></expan>: <expan>or<ex>ator</ex></expan> adiecit: </foreign>'
    assert_equal_fragment_transform '~|<:et|corr|ec:> (c(etera)): test adiecit(or(ator)): |~la ', '<foreign xml:lang="la"><choice><corr>et</corr><sic>ec</sic></choice> <expan>c<ex>etera</ex></expan>: test adiecit<expan>or<ex>ator</ex></expan>: </foreign>'
    assert_equal_fragment_transform '~|[Ac]holius (d(ixit)): |~la ', '<foreign xml:lang="la"><supplied reason="lost">Ac</supplied>holius <expan>d<ex>ixit</ex></expan>: </foreign>'
    assert_equal_fragment_transform '~|[Ac]holius (d(ixit))|~la ', '<foreign xml:lang="la"><supplied reason="lost">Ac</supplied>holius <expan>d<ex>ixit</ex></expan></foreign>'
    assert_equal_fragment_transform '~|[Ac]holius (d(ixit)) |~la ', '<foreign xml:lang="la"><supplied reason="lost">Ac</supplied>holius <expan>d<ex>ixit</ex></expan> </foreign>'
    assert_equal_fragment_transform '~|Acholius dixit: |~la ', '<foreign xml:lang="la">Acholius dixit: </foreign>'
    assert_equal_fragment_transform '\κα̣ὶ̣ μὴ ὁμολογη〚.1〛/', '<add place="above">κ<unclear>αὶ</unclear> μὴ ὁμολογη<del rend="erasure"><gap reason="illegible" quantity="1" unit="character"/></del></add>'
    assert_equal_fragment_transform '(~|IỊỊCyr|~la (enaica))', '<expan><foreign xml:lang="la">I<unclear>II</unclear>Cyr</foreign><ex>enaica</ex></expan>'
    assert_equal_fragment_transform '~|~||Ἑρεννίαν Γέμελλαν||~tall|~grc ', '<foreign xml:lang="grc"><hi rend="tall">Ἑρεννίαν Γέμελλαν</hi></foreign>'
    assert_equal_fragment_transform '<:(Κών̣ων̣(ος))=BL 8.470|ed|Κω.2ω <:vestig |corr|*monogram*:>:>', '<app type="editorial"><lem resp="BL 8.470"><expan>Κώ<unclear>ν</unclear>ω<unclear>ν</unclear><ex>ος</ex></expan></lem><rdg>Κω<gap reason="illegible" quantity="2" unit="character"/>ω <choice><corr><gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></corr><sic><g type="monogram"/></sic></choice></rdg></app>'
    assert_equal_fragment_transform '<:<:εὐωνύμου|corr||_ε̣υ̣_|ω|_ν̣υ̣[μ]ω_|:>|alt|εὐονύμῳ:>', '<app type="alternative"><lem><choice><corr>εὐωνύμου</corr><sic><supplied evidence="parallel" reason="undefined"><unclear>ευ</unclear></supplied>ω<supplied evidence="parallel" reason="undefined"><unclear>νυ</unclear><supplied reason="lost">μ</supplied>ω</supplied></sic></choice></lem><rdg>εὐονύμῳ</rdg></app>'
    assert_equal_fragment_transform '<:~|taṇṭẹṣ|~la |alt|~|taṇṭọṣ|~la :>', '<app type="alternative"><lem><foreign xml:lang="la">ta<unclear>ntes</unclear></foreign></lem><rdg><foreign xml:lang="la">ta<unclear>ntos</unclear></foreign></rdg></app>'
    assert_equal_fragment_transform '<:(~|Ọṛ|~la (mum))|alt|(~|Ụṛ|~la (mum)):>', '<app type="alternative"><lem><expan><foreign xml:lang="la"><unclear>Or</unclear></foreign><ex>mum</ex></expan></lem><rdg><expan><foreign xml:lang="la"><unclear>Ur</unclear></foreign><ex>mum</ex></expan></rdg></app>'
    assert_equal_fragment_transform '<:.2|alt|vestig :>', '<app type="alternative"><lem><gap reason="illegible" quantity="2" unit="character"/></lem><rdg><gap reason="illegible" extent="unknown" unit="character"><desc>vestiges</desc></gap></rdg></app>'
  end
    
  def test_milestone
    assert_equal_fragment_transform '----', '<milestone rend="paragraphos" unit="undefined"/>'
    assert_equal_fragment_transform '[----]', '<supplied reason="lost"><milestone rend="paragraphos" unit="undefined"/></supplied>'
    assert_equal_fragment_transform '[συμφωνῶ ----]', '<supplied reason="lost">συμφωνῶ <milestone rend="paragraphos" unit="undefined"/></supplied>'
    assert_equal_fragment_transform '[ ---- ἐγγ]', '<supplied reason="lost"> <milestone rend="paragraphos" unit="undefined"/> ἐγγ</supplied>'
    assert_equal_fragment_transform '[συμφωνῶ ---- ἐγγ]', '<supplied reason="lost">συμφωνῶ <milestone rend="paragraphos" unit="undefined"/> ἐγγ</supplied>'
    assert_equal_fragment_transform '[----(?)]', '<supplied reason="lost" cert="low"><milestone rend="paragraphos" unit="undefined"/></supplied>'
    assert_equal_fragment_transform '[συμφωνῶ ----(?)]', '<supplied reason="lost" cert="low">συμφωνῶ <milestone rend="paragraphos" unit="undefined"/></supplied>'
    assert_equal_fragment_transform '[ ---- ἐγγ(?)]', '<supplied reason="lost" cert="low"> <milestone rend="paragraphos" unit="undefined"/> ἐγγ</supplied>'
    assert_equal_fragment_transform '[συμφωνῶ ---- ἐγγ(?)]', '<supplied reason="lost" cert="low">συμφωνῶ <milestone rend="paragraphos" unit="undefined"/> ἐγγ</supplied>'
    assert_equal_fragment_transform '<---->', '<supplied reason="omitted"><milestone rend="paragraphos" unit="undefined"/></supplied>'
    assert_equal_fragment_transform '<----(?)>', '<supplied reason="omitted" cert="low"><milestone rend="paragraphos" unit="undefined"/></supplied>'
    assert_equal_fragment_transform '~~~~~~~~', '<milestone rend="wavy-line" unit="undefined"/>'
    assert_equal_fragment_transform '--------', '<milestone rend="horizontal-rule" unit="undefined"/>'
    assert_equal_fragment_transform '###', '<milestone rend="box" unit="undefined"/>'
  end
    
  def test_figure
    ['seal', 'stamp', 'drawing'].each do |figdesc|
      assert_equal_fragment_transform "\##{figdesc} ", "<figure><figDesc>#{figdesc}</figDesc></figure>"
    end
  end
    
  def test_certainty
    assert_equal_fragment_transform '[<:λίβα(?)=BL 8.236|ed|.4:> τοπαρχίας ]', '<supplied reason="lost"><app type="editorial"><lem resp="BL 8.236">λίβα<certainty match=".." locus="value"/></lem><rdg><gap reason="illegible" quantity="4" unit="character"/></rdg></app> τοπαρχίας </supplied>'
  end
  
  def test_langlist_exhaustive
    ['Arabic', 'Aramaic', 'Coptic', 'Demotic', 'Gothic', 'Hebrew', 'Hieratic', 'Nabatean', 'Syriac'].each do |lang|
    assert_equal_fragment_transform "(Lang: #{lang} 2 char)", "<gap reason=\"ellipsis\" quantity=\"2\" unit=\"character\"><desc>#{lang}</desc></gap>"
    assert_equal_fragment_transform "(Lang: #{lang} ? char)", "<gap reason=\"ellipsis\" extent=\"unknown\" unit=\"character\"><desc>#{lang}</desc></gap>"
    assert_equal_fragment_transform "(Lang: #{lang} 2 lines)", "<gap reason=\"ellipsis\" quantity=\"2\" unit=\"line\"><desc>#{lang}</desc></gap>"
    assert_equal_fragment_transform "(Lang: #{lang} ? lines)", "<gap reason=\"ellipsis\" extent=\"unknown\" unit=\"line\"><desc>#{lang}</desc></gap>"
    end
  end
  
  def test_nontrans
    assert_equal_fragment_transform '(Lines: 3 non transcribed)', '<gap reason="ellipsis" quantity="3" unit="line"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Lines: 3 non transcribed(?))', '<gap reason="ellipsis" quantity="3" unit="line"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Lines: ca.3 non transcribed)', '<gap reason="ellipsis" quantity="3" unit="line" precision="low"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Lines: ca.3 non transcribed(?))', '<gap reason="ellipsis" quantity="3" unit="line" precision="low"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Lines: ? non transcribed)', '<gap reason="ellipsis" extent="unknown" unit="line"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Lines: ? non transcribed(?))', '<gap reason="ellipsis" extent="unknown" unit="line"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Lines: 3-5 non transcribed)', '<gap reason="ellipsis" atLeast="3" atMost="5" unit="line"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Lines: 3-5 non transcribed(?))', '<gap reason="ellipsis" atLeast="3" atMost="5" unit="line"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Chars: 3 non transcribed)', '<gap reason="ellipsis" quantity="3" unit="character"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Chars: 3 non transcribed(?))', '<gap reason="ellipsis" quantity="3" unit="character"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Chars: ca.3 non transcribed)', '<gap reason="ellipsis" quantity="3" unit="character" precision="low"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Chars: ca.3 non transcribed(?))', '<gap reason="ellipsis" quantity="3" unit="character" precision="low"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Chars: ? non transcribed)', '<gap reason="ellipsis" extent="unknown" unit="character"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Chars: ? non transcribed(?))', '<gap reason="ellipsis" extent="unknown" unit="character"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Chars: 3-5 non transcribed)', '<gap reason="ellipsis" atLeast="3" atMost="5" unit="character"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Chars: 3-5 non transcribed(?))', '<gap reason="ellipsis" atLeast="3" atMost="5" unit="character"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Column: 3 non transcribed)', '<gap reason="ellipsis" quantity="3" unit="column"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Column: 3 non transcribed(?))', '<gap reason="ellipsis" quantity="3" unit="column"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Column: ca.3 non transcribed)', '<gap reason="ellipsis" quantity="3" unit="column" precision="low"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Column: ca.3 non transcribed(?))', '<gap reason="ellipsis" quantity="3" unit="column" precision="low"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Column: ? non transcribed)', '<gap reason="ellipsis" extent="unknown" unit="column"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Column: ? non transcribed(?))', '<gap reason="ellipsis" extent="unknown" unit="column"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
    assert_equal_fragment_transform '(Column: 3-5 non transcribed)', '<gap reason="ellipsis" atLeast="3" atMost="5" unit="column"><desc>non transcribed</desc></gap>'
    assert_equal_fragment_transform '(Column: 3-5 non transcribed(?))', '<gap reason="ellipsis" atLeast="3" atMost="5" unit="column"><desc>non transcribed</desc><certainty match=".." locus="name"/></gap>'
  end
  
  def test_linenumber_specials
    assert_equal_fragment_transform '2/3,ms. ', '<lb n="2/3,ms"/>'
    assert_equal_fragment_transform '396/397,minf. ', '<lb n="396/397,minf"/>'
    assert_equal_fragment_transform '18. ', '<lb n="18"/>'
    assert_equal_fragment_transform '18,ms7. ', '<lb n="18,ms7"/>'
    assert_equal_fragment_transform '8,ms. ', '<lb n="8,ms"/>'
    assert_equal_fragment_transform '8ms. ', '<lb n="8ms"/>'
    assert_equal_fragment_transform '8/ms. ', '<lb n="8/ms"/>'
    assert_equal_fragment_transform '1/2. ', '<lb n="1/2"/>'
    assert_equal_fragment_transform '3,4. ', '<lb n="3,4"/>'
    assert_equal_fragment_transform '(1,ms, perpendicular)', '<lb n="1,ms" rend="perpendicular"/>'
    assert_equal_fragment_transform '(1/side, perpendicular)', '<lb n="1/side" rend="perpendicular"/>'
    assert_equal_fragment_transform '(1.-, perpendicular)', '<lb n="1" rend="perpendicular" break="no"/>'
    assert_equal_fragment_transform '(2.-, inverse)', '<lb n="2" rend="inverse" break="no"/>'
    assert_equal_fragment_transform '3.- ', '<lb n="3" break="no"/>'
    assert_equal_fragment_transform '4. ', '<lb n="4"/>'
    assert_equal_fragment_transform '<:ὑπηR 8.- [ρετῶ]ν=bgu 3 p.1|ed|[.7]ν:>', '<app type="editorial"><lem resp="bgu 3 p.1">ὑπηR <lb n="8" break="no"/><supplied reason="lost">ρετῶ</supplied>ν</lem><rdg><gap reason="lost" quantity="7" unit="character"/>ν</rdg></app>'
    assert_equal_fragment_transform '<:Πα[νε]φρόμ 23.- μεως|ed|Πα[νε]φρέμμεως:>', '<app type="editorial"><lem>Πα<supplied reason="lost">νε</supplied>φρόμ <lb n="23" break="no"/>μεως</lem><rdg>Πα<supplied reason="lost">νε</supplied>φρέμμεως</rdg></app>'
    assert_equal_fragment_transform '<:Πα[νε]φρόμ (2.-, inverse)μεως|ed|Πα[νε]φρέμμεως:>', '<app type="editorial"><lem>Πα<supplied reason="lost">νε</supplied>φρόμ <lb n="2" rend="inverse" break="no"/>μεως</lem><rdg>Πα<supplied reason="lost">νε</supplied>φρέμμεως</rdg></app>'
  end
  
  def test_simple_reversibility
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1. test=>", "<S=.grc<=1. test=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1. test1\n2. test2=>", "<S=.grc<=1. test1\n2. test2=>"
  end
  
  def test_multiple_ab
    #test multiple ab sections
    assert_equal_fragment_transform '{.1ab}=><=12. {ab.1}', '<surplus><gap reason="illegible" quantity="1" unit="character"/>ab</surplus></ab><ab><lb n="12"/><surplus>ab<gap reason="illegible" quantity="1" unit="character"/></surplus>'
  end
  
  def test_line_number_formats
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1. test=>", "<S=.grc<=1. test=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1a. test1a=>", "<S=.grc<=1a. test1a=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=4/5. test45=>", "<S=.grc<=4/5. test45=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=14/15. test1415=>", "<S=.grc<=14/15. test1415=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1,ms. test1ms=>", "<S=.grc<=1,ms. test1ms=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=17,ms. test17ms=>", "<S=.grc<=17,ms. test17ms=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=(1,ms, perpendicular) test1ms=>", "<S=.grc<=(1,ms, perpendicular) test1ms=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=(1/side, perpendicular) test17ms=>", "<S=.grc<=(1/side, perpendicular) test17ms=>"
    #above test with break no
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1.- test=>", "<S=.grc<=1.- test=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1a.- test1a=>", "<S=.grc<=1a.- test1a=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=4/5.- test45=>", "<S=.grc<=4/5.- test45=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=14/15.- test1415=>", "<S=.grc<=14/15.- test1415=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1,ms.- test1ms=>", "<S=.grc<=1,ms.- test1ms=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=17,ms.- test17ms=>", "<S=.grc<=17,ms.- test17ms=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=(1,ms.-, perpendicular) test1ms=>", "<S=.grc<=(1,ms.-, perpendicular) test1ms=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=(1/side.-, perpendicular) test17ms=>", "<S=.grc<=(1/side.-, perpendicular) test17ms=>"
  end
  
  def test_p5_linenumber_funky_special
    assert_equal_fragment_transform '18. ', '<lb n="18"/>'
    assert_equal_fragment_transform '18,ms7. ', '<lb n="18,ms7"/>'
    assert_equal_fragment_transform '8,ms. ', '<lb n="8,ms"/>'
    assert_equal_fragment_transform '8ms. ', '<lb n="8ms"/>'
    assert_equal_fragment_transform '8/ms. ', '<lb n="8/ms"/>'
    assert_equal_fragment_transform '1/2. ', '<lb n="1/2"/>'
    assert_equal_fragment_transform '3,4. ', '<lb n="3,4"/>'
    assert_equal_fragment_transform '(1,ms, perpendicular)', '<lb n="1,ms" rend="perpendicular"/>'
    assert_equal_fragment_transform '(1/side, perpendicular)', '<lb n="1/side" rend="perpendicular"/>'
  end
  
  def test_p5_linenumber_funky_special_break_no
    assert_equal_fragment_transform '18.- ', '<lb n="18" break="no"/>'
    assert_equal_fragment_transform '18,ms7.- ', '<lb n="18,ms7" break="no"/>'
    assert_equal_fragment_transform '8,ms.- ', '<lb n="8,ms" break="no"/>'
    assert_equal_fragment_transform '8ms.- ', '<lb n="8ms" break="no"/>'
    assert_equal_fragment_transform '8/ms.- ', '<lb n="8/ms" break="no"/>'
    assert_equal_fragment_transform '1/2.- ', '<lb n="1/2" break="no"/>'
    assert_equal_fragment_transform '3,4.- ', '<lb n="3,4" break="no"/>'
    assert_equal_fragment_transform '(1,ms.-, perpendicular)', '<lb n="1,ms" rend="perpendicular" break="no"/>'
    assert_equal_fragment_transform '(1/side.-, perpendicular)', '<lb n="1/side" rend="perpendicular" break="no"/>'
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
        #str = "<=" + str + "=>"
        str = "<S=.grc<=" + str + "=>"
        assert_equal_non_xml_to_xml_to_non_xml str, str
      #end
    #end
  end
  
  def test_xml_trailing_newline_stripped
    # added \n at end to prove newline not stripped anymore
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1. test\n=>", "<S=.grc<=1. test\n=>"
    assert_equal_non_xml_to_xml_to_non_xml "<S=.grc<=1. test1\n2. test2\n=>", "<S=.grc<=1. test1\n2. test2\n=>"
  end
  
  def test_unicode_greek_reversibility
    assert_equal_non_xml_to_xml_to_non_xml '<S=.grc<=1. ςερτυθιοπασδφγηξκλζχψωβνμ=>', '<S=.grc<=1. ςερτυθιοπασδφγηξκλζχψωβνμ=>'
  end
  
  # def test_xsugar_reversibility_true
  #   assert @xsugar.reversible?
  # end
  end
end
