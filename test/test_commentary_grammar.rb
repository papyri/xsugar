if(RUBY_PLATFORM == 'java')
  require File.join(File.dirname(__FILE__), 'test_commentary_helper')

  class CommentaryGrammarTest < Test::Unit::TestCase
    
    def test_emphasis_b
      assert_equal_fragment_transform '<b make this bold>', '<emph rend="bold">make this bold</emph>'
    end 
 
    def test_emphasis_i
      assert_equal_fragment_transform '<i make this italical>', '<emph rend="italics">make this italical</emph>'
    end 
 
    def test_bib
      assert_equal_fragment_transform '<the words for the link||bgu;7;33>', '<pn ref="bgu;7;33">the words for the link</pn>'      
    end 
    
    def test_url
      assert_equal_fragment_transform '<the words for the link|www.somesite.com/index.html>', '<a href="www.somesite.com/index.html">the words for the link</a>'
      assert_equal_fragment_transform '<the words for the link|www.somesite.com/recall.php?do=house boat>', '<a href="www.somesite.com/recall.php?do=house boat">the words for the link</a>'
    end 
  
  end
 
end
