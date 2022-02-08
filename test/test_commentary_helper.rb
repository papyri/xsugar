# encoding: utf-8
if(RUBY_PLATFORM == 'java')
  require 'test/unit'
  require File.join(File.dirname(__FILE__), *%w".. lib rxsugar")
  require File.join(File.dirname(__FILE__), 'test_commentary_assertions')
  
  class CommentaryGrammarTest < Test::Unit::TestCase
    include RXSugar::RXSugarHelper
    include CommentaryGrammarAssertions
    
    def setup     
      @xsugar = rxsugar_from_grammar(COMMENTARY_GRAMMAR)
    end
    
    protected    
  end
end
