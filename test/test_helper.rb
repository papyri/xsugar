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
    
    def lb(xmlline)
      return "<lb></lb>#{xmlline}"
    end
    
    def assert_equal_fragment_transform(expected, input)
      assert_equal ab(lb(expected)), @xsugar.non_xml_to_xml(input)
    end
    
    def assert_equal_non_xml_to_xml_to_non_xml(expected, input)
      assert_equal expected, @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml(input))
    end
end