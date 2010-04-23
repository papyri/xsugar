if(RUBY_PLATFORM == 'java')
  require File.join(File.dirname(__FILE__), 'test_translation_helper')

  class TranslationGrammarTest < Test::Unit::TestCase
 
    #-------------------new for translation----------------------
    
    def test_term
      assert_equal_fragment_transform '<cow=vaca>', '<term target="vaca">cow</term>'
      assert_equal_fragment_transform '<cow=vaca~sp>', '<term target="vaca" xml:lang="sp">cow</term>'
    end
 
   
 
 
    def test_del      
      assert_equal_fragment_transform 'a〚bc〛', 'a<del>bc</del>'
      assert_equal_fragment_transform 'ab〚c def g〛hi', 'ab<del>c def g</del>hi'
    end
    
 
   #===================end new for translation===================
  
  
  

  
    #-----------------changed from transcription-----------------------
    def test_milestone
      assert_equal_fragment_transform '(1). ', '<milestone unit="line" n="1"/>'
      assert_equal_fragment_transform '(1).div ', '<milestone unit="line" n="1" rend="break"/>'
    end
    
    def test_foreign_lang
      assert_equal_fragment_transform '~|veni vedi vici|~la ', '<foreign xml:lang="la">veni vedi vici</foreign>'      
    end
    
    def test_app_lem
      assert_equal_fragment_transform '<:a|BGU:1.215|:>', '<app type="BGU"><lem resp="1.215">a</lem></app>'
      assert_equal_fragment_transform '<:a|BGU_DDbDP:1.215|:>', '<app type="BGU_DDbDP"><lem resp="1.215">a</lem></app>'
    end
  
  
    
    #==================end changed from transcription
    
        
    #-------------OK & unchanged from transcription-------------------
         


  
    # http://www.stoa.org/epidoc/gl/5/lostcertain.html
    # but extent="unknown" not explicitly combined with unit="character" in guidelines
    def test_lost_gap_unknown
      # Some unknown number of lost characters
      assert_equal_fragment_transform '[.?]', '<gap reason="lost" extent="unknown" unit="character"/>'
    end
    
  
    # http://www.stoa.org/epidoc/gl/5/vestiges.html
    def test_illegible_gap_unknown
      # Some unknown number of illegible letters
      assert_equal_fragment_transform '.?', '<gap reason="illegible" extent="unknown" unit="character"/>'
    end

    #=============end OK & unchanged from transcription===================
    
    
    
    
    
    
    
    
    
  end
 
end
