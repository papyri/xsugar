require 'test/unit'
require File.join(File.dirname(__FILE__), *%w".. lib xsugar")

class GrammarTest < Test::Unit::TestCase
  def setup
    grammar_file = File.join(File.dirname(__FILE__), *%w".. epidoc.xsg")
    xsg = File.readlines(grammar_file).to_s
    @xsugar = RXSugar.new(xsg)
  end
  
  protected    
    def ab(xml)
      return "<ab>#{xml}</ab>"
    end
end