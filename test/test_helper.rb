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
    
    def assert_equal_fragment_transform(xml_fragment, non_xml_fragment)
      assert_equal ab(lb(xml_fragment)), @xsugar.non_xml_to_xml(non_xml_fragment)
      assert_equal non_xml_fragment, @xsugar.xml_to_non_xml(ab(lb(xml_fragment)))
      assert_equal_non_xml_to_xml_to_non_xml non_xml_fragment, non_xml_fragment
      assert_equal_xml_fragment_to_non_xml_to_xml_fragment xml_fragment, xml_fragment
    end
    
    def assert_equal_non_xml_to_xml_to_non_xml(expected, input)
      assert_equal expected, @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml(input))
    end
    
    def assert_equal_xml_fragment_to_non_xml_to_xml_fragment(expected, input)
      assert_equal ab(lb(expected)), @xsugar.non_xml_to_xml(@xsugar.xml_to_non_xml(ab(lb(input))))
    end
end