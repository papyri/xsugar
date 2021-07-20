# encoding: utf-8
if(RUBY_PLATFORM == 'java')
  require 'test/unit'
  require File.join(File.dirname(__FILE__), *%w".. lib rxsugar")
  require File.join(File.dirname(__FILE__), 'test_translation_assertions')
  
  class TranslationGrammarTest < Test::Unit::TestCase
    include RXSugar::RXSugarHelper
    include TranslationGrammarAssertions
    
    def setup     
      @xsugar = rxsugar_from_grammar(TRANSLATION_GRAMMAR)
    end
    
    protected    
  end
end
