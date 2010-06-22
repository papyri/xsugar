if(RUBY_PLATFORM == 'java')
  require File.join(File.dirname(__FILE__), 'test_translation_helper')

  class TranslationGrammarTest < Test::Unit::TestCase
 
    #-------------------new for translation----------------------
    
    def test_term
      assert_equal_fragment_transform '<cow=vaca>', '<term target="vaca">cow</term>'
      assert_equal_fragment_transform '<def=target>', '<term target="target">def</term>'
      assert_equal_fragment_transform '<cow=vaca~la>', '<term target="vaca" xml:lang="la">cow</term>'
      assert_equal_fragment_transform '<cow=vaca~grc-Latn>', '<term target="vaca" xml:lang="grc-Latn">cow</term>'
      
      assert_equal_fragment_transform '<scrutinized (?)=epikekrimenos>', '<term target="epikekrimenos">scrutinized (?)</term>'
      assert_equal_fragment_transform '<Treasuries\' quarter=amphTam>', '<term target="amphTam">Treasuries\' quarter</term>'
      
      assert_equal_fragment_transform '<elect_=enklero>', '<term target="enklero">elect_</term>'
      assert_equal_fragment_transform '<von 1/100 und 1/50=rkain>', '<term target="rkain">von 1/100 und 1/50</term>'
      
      assert_equal_fragment_transform '<[...]-Viertels=amphodon>', '<term target="amphodon"><gap reason="lost" extent="unknown" unit="character"/>-Viertels</term>'
      
      #assert_equal_fragment_transform '<~|katoikoi(?)|~la=katoikos>', '<term target="katoikos" xml:lang="la"><foreign xml:lang="la">katoikoi(?)</foreign></term>'
      
    end 
 
    def test_del      
      assert_equal_fragment_transform 'a〚bc〛', 'a<del>bc</del>'
      assert_equal_fragment_transform 'ab〚c def g〛hi', 'ab<del>c def g</del>hi'
      
      assert_equal_fragment_transform 'a〚b=c〛', 'a<del>b=c</del>'
      assert_equal_fragment_transform '〚eight drachmas, = 8 drachmas,〛', '<del>eight drachmas, = 8 drachmas,</del>'
    end
    
    def test_textpart
      assert_equal_fragment_transform '<D=.a.recto <=stuff=>=D>', '<div n="a" subtype="recto" type="textpart"><p>stuff</p></div>'
      assert_equal_fragment_transform '<D=.a <=stuff=>=D>', '<div n="a" type="textpart"><p>stuff</p></div>'
      #assert_equal_fragment_transform '<D=.a hi=D>', '<div n="a" type="textpart">hi</div>'
      #assert_equal_fragment_transform '<D= hi =D>', '<div type="textpart">hi</div>'

    #need to know where p tag is allowed...
    # do they want trans-p-divs or trans-divs-p 
    #  via tei docs should be transdiv-p-textpartdivs-p, docs state each div should have a container?
    #  transdiv-p note that textpartdivs-p are optional
    end
 
   #===================end new for translation===================
  
  
  

  
    #-----------------changed from transcription-----------------------
    
    
    def test_note
      assert_equal_fragment_transform '/*en abcdefg*/', '<note xml:lang="en">abcdefg</note>'
      assert_equal_fragment_transform '/*de abcdefg*/', '<note xml:lang="de">abcdefg</note>'
      
      #assert_equal_fragment_transform '/*abcdefg*/', '<note xml:lang="en">abcdefg</note>'
      
      assert_equal_fragment_transform '/*en ?*/', '<note xml:lang="en">?</note>'
      assert_equal_fragment_transform '/*de ?*/', '<note xml:lang="de">?</note>'
      
      assert_equal_fragment_transform '/*en End of sentence.*/', '<note xml:lang="en">End of sentence.</note>'
      assert_equal_fragment_transform '/*de End of sentence.*/', '<note xml:lang="de">End of sentence.</note>'
      
      
      assert_equal_fragment_transform '/*en text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4*/', '<note xml:lang="en">text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4</note>'
      assert_equal_fragment_transform '/*de text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4*/', '<note xml:lang="de">text continued at SB 16,13060 + BGU 13,2270 + P.Graux. 3,30 + P.Col. 2,1 recto 4</note>'
    end
    
    
    
    def test_milestone
      #assert_equal_fragment_transform '(1). ', '<milestone unit="line" n="1"/>'
      #assert_equal_fragment_transform '(1).div ', '<milestone unit="line" n="1" rend="break"/>'
      
      assert_equal_fragment_transform '(1)', '<milestone unit="line" n="1"/>'
      assert_equal_fragment_transform '((1))', '<milestone unit="line" n="1" rend="break"/>'
      
    end
    
    def test_foreign_lang
      assert_equal_fragment_transform '~|veni vedi vici|~la ', '<foreign xml:lang="la">veni vedi vici</foreign>'  
      
      #assert_equal_fragment_transform '~|katoikoi(?)|~la', '<foreign xml:lang="la">katoikoi(?)</foreign>'
          
      #not allowed assert_equal_fragment_transform  '~| pittakiarches|~la ', '<foreign xml:lang="la"><term xml:lang="la">pittakiarches</term></foreign>'
      
      assert_equal_fragment_transform '~|Am unteren Rand des Papyrus in entgegengesetzter Richtung:|~la ', '<foreign xml:lang="la">Am unteren Rand des Papyrus in entgegengesetzter Richtung:</foreign>'
      #assert_equal_fragment_transform '~|Am unteren Rand des Papyrus in entgegengesetzter Richtung|~la ', '<foreign xml:lang="la">Am unteren Rand des Papyrus in entgegengesetzter Richtung</foreign>'
    end
    
    def test_app_lem
    
      assert_equal_fragment_transform '<:a|:|:>', '<app><lem>a</lem></app>'
      
      assert_equal_fragment_transform '<:a|BGU:|:>', '<app type="BGU"><lem>a</lem></app>'
      assert_equal_fragment_transform '<:a|BGU:1.215|:>', '<app type="BGU"><lem resp="1.215">a</lem></app>'
      
      assert_equal_fragment_transform '<:a|BGU_DDbDP:1.215|:>', '<app type="BGU_DDbDP"><lem resp="1.215">a</lem></app>'
      assert_equal_fragment_transform '<:a|BGU_DDbDP:|:>', '<app type="BGU_DDbDP"><lem>a</lem></app>'
      
      assert_equal_fragment_transform '<:für die|BGU:BL II 2, S. 20|:>',  '<app type="BGU"><lem resp="BL II 2, S. 20">für die</lem></app>'
      

    end
  
  
    def test_random
      assert_equal_fragment_transform 'a place you live', 'a place you live'    	    
      assert_equal_fragment_transform 'house : a place you live', 'house : a place you live'
      assert_equal_fragment_transform 'store:where you shop', 'store:where you shop'
      
    
    end
    
    #==================end changed from transcription
    
        
    #-------------OK & unchanged from transcription-------------------
         


  
    # http://www.stoa.org/epidoc/gl/5/lostcertain.html
    # but extent="unknown" not explicitly combined with unit="character" in guidelines
    def test_lost_gap_unknown
      # Some unknown number of lost characters
      #assert_equal_fragment_transform '[.?]', '<gap reason="lost" extent="unknown" unit="character"/>'
      assert_equal_fragment_transform '[...]', '<gap reason="lost" extent="unknown" unit="character"/>'
    end
    
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    def test_illegible_gap_unknown
      # Some unknown number of illegible letters
      #assert_equal_fragment_transform '.?', '<gap reason="illegible" extent="unknown" unit="character"/>'
      assert_equal_fragment_transform '...', '<gap reason="illegible" extent="unknown" unit="character"/>'
    end

    #=============end OK & unchanged from transcription===================
    
    
    
    
    
    
    
    
    
  end
 
end
