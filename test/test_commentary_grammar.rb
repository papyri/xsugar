if(RUBY_PLATFORM == 'java')
  require File.join(File.dirname(__FILE__), 'test_commentary_helper')

  class CommentaryGrammarTest < Test::Unit::TestCase

#=begin    
    def test_paragraph
      assert_equal_fragment_transform '

*make this bold*', '<p><emph rend="bold">make this bold</emph></p>'
      assert_equal_fragment_transform '

    *make this bold*

    _underline here_', '<p>    <emph rend="bold">make this bold</emph></p><p>    <emph rend="underline">underline here</emph></p>'
    end
    
    
    def test_emphasis_nest
      assert_equal_fragment_transform '*make _this_ bold*', '<emph rend="bold">make <emph rend="underline">this</emph> bold</emph>'
      assert_equal_fragment_transform '|make *this* bold|', '<emph rend="italics">make <emph rend="bold">this</emph> bold</emph>'
      assert_equal_fragment_transform '_make |this| bold_', '<emph rend="underline">make <emph rend="italics">this</emph> bold</emph>'
      assert_equal_fragment_transform '``make *this* a quote\'\'', '<emph rend="quote">make <emph rend="bold">this</emph> a quote</emph>'
      assert_equal_fragment_transform '*make* this *bold*', '<emph rend="bold">make</emph> this <emph rend="bold">bold</emph>'
      assert_equal_fragment_transform '|make| this |bold|', '<emph rend="italics">make</emph> this <emph rend="italics">bold</emph>'
      assert_equal_fragment_transform '_make_ this _bold_', '<emph rend="underline">make</emph> this <emph rend="underline">bold</emph>'
      assert_equal_fragment_transform '``make\'\' this ``a quote\'\'', '<emph rend="quote">make</emph> this <emph rend="quote">a quote</emph>'
      assert_equal_fragment_transform '``make\'\' *this* _a_ |quote|', '<emph rend="quote">make</emph> <emph rend="bold">this</emph> <emph rend="underline">a</emph> <emph rend="italics">quote</emph>'
      assert_equal_fragment_transform '``make *this _a |quote|_*\'\'', '<emph rend="quote">make <emph rend="bold">this <emph rend="underline">a <emph rend="italics">quote</emph></emph></emph></emph>'
    end
    
    def test_emphasis_bold
      assert_equal_fragment_transform '*make this bold*', '<emph rend="bold">make this bold</emph>'
    end
 
    def test_emphasis_italics
      assert_equal_fragment_transform '|make this italical|', '<emph rend="italics">make this italical</emph>'
    end 
    
    def test_emphasis_underline
      assert_equal_fragment_transform '_make this underline_', '<emph rend="underline">make this underline</emph>'
    end 
    
    def test_emphasis_quote
      assert_equal_fragment_transform '``make this a quote\'\'', '<emph rend="quote">make this a quote</emph>'
    end
 

    def test_footnote
      assert_equal_fragment_transform '<:fn=this is the footnote:>', '<note type="footnote" xml:lang="en">this is the footnote</note>'
    end
#=end
    def test_bib
      assert_equal_fragment_transform '<:the words for the link|bibl/papyri.info/ddbdp/bgu;7;33:>', '<listBibl><bibl><ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref></bibl></listBibl>'
      assert_equal_fragment_transform '<:the words for the link|bibl/papyri.info/ddbdp/bgu;7;33|p=2:>', '<listBibl><bibl><ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref><biblScope type="pp">2</biblScope></bibl></listBibl>'
      assert_equal_fragment_transform '<:the words for the link|bibl/papyri.info/ddbdp/bgu;7;33|p=2-4:>', '<listBibl><bibl><ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref><biblScope type="pp">2-4</biblScope></bibl></listBibl>'
      assert_equal_fragment_transform '<:the words for the link|bibl/papyri.info/ddbdp/bgu;7;33|p=II:>', '<listBibl><bibl><ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref><biblScope type="pp">II</biblScope></bibl></listBibl>'
      assert_equal_fragment_transform '<:the words for the link|bibl/papyri.info/ddbdp/bgu;7;33|p=II-IV:>', '<listBibl><bibl><ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref><biblScope type="pp">II-IV</biblScope></bibl></listBibl>'
      assert_equal_fragment_transform '<:the words for the link|bibl/papyri.info/ddbdp/bgu;7;33|p=ii:>', '<listBibl><bibl><ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref><biblScope type="pp">ii</biblScope></bibl></listBibl>'
      assert_equal_fragment_transform '<:the words for the link|bibl/papyri.info/ddbdp/bgu;7;33|p=ii-iv:>', '<listBibl><bibl><ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref><biblScope type="pp">ii-iv</biblScope></bibl></listBibl>'
      assert_equal_fragment_transform '<:the words for the link|bibl/papyri.info/ddbdp/bgu;7;33|v=3|i=25|ch=7|p=ii-iv|l=47:>', '<listBibl><bibl><ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref><biblScope type="vol">3</biblScope><biblScope type="issue">25</biblScope><biblScope type="chap">7</biblScope><biblScope type="pp">ii-iv</biblScope><biblScope type="ll">47</biblScope></bibl></listBibl>'
    end 
    
    def test_url
      assert_equal_fragment_transform '<:the words for the link|ddbdp/bgu;7;33:>', '<ref target="http://papyri.info/ddbdp/bgu;7;33">the words for the link</ref>'
      assert_equal_fragment_transform '<:the words for the link|hgv/bgu;7;33:>', '<ref target="http://papyri.info/hgv/bgu;7;33">the words for the link</ref>'
      assert_equal_fragment_transform '<:the words for the link|apis/bgu;7;33:>', '<ref target="http://papyri.info/apis/bgu;7;33">the words for the link</ref>'
      assert_equal_fragment_transform '<:the words for the link|www.somesite.com/index.html:>', '<ref target="http://www.somesite.com/index.html">the words for the link</ref>'
      assert_equal_fragment_transform '<:the words for the link|www.somesite.com/recall.php?do=house boat:>', '<ref target="http://www.somesite.com/recall.php?do=house boat">the words for the link</ref>'
    end 

  end
 
end
