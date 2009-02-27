if(RUBY_PLATFORM == 'java')
  require 'test/unit'
  require File.join(File.dirname(__FILE__), *%w".. lib rxsugar")
  require File.join(File.dirname(__FILE__), 'test_assertions')
  
  class GrammarTest < Test::Unit::TestCase
    include RXSugar::RXSugarHelper
    include GrammarAssertions
    
    def setup
      @xsugar = rxsugar_from_grammar
    end
    
    protected    
  end
end