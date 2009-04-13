require 'test/unit'

module GrammarAssertions
  class ParseError < ::StandardError; end
  class XMLParseError < ParseError; end
  class NonXMLParseError < ParseError; end
  
  include Test::Unit::Assertions
  
  def ab(xml)
    return "<ab>#{xml}</ab>"
  end

  def lb(xmlline)
    return "<lb n=\"1\"></lb>#{xmlline}"
  end

  def assert_equal_fragment_transform(non_xml_fragment, xml_fragment)
    non_xml_fragment = "1. #{non_xml_fragment}"
    assert_equal ab(lb(xml_fragment)), @xsugar.non_xml_to_xml(non_xml_fragment)
    assert_equal non_xml_fragment, @xsugar.xml_to_non_xml(ab(lb(xml_fragment)))
    assert_equal_non_xml_to_xml_to_non_xml non_xml_fragment, non_xml_fragment
    assert_equal_xml_fragment_to_non_xml_to_xml_fragment xml_fragment, xml_fragment
  end
  
  def assert_equal_non_xml_to_xml_to_non_xml(expected, input)
    assert_equal expected, @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml(input))
  end

  def assert_equal_xml_fragment_to_non_xml_to_xml_fragment(expected, input)
    begin
      xml_to_non_xml = @xsugar.xml_to_non_xml(ab(lb(input)))
    rescue NativeException => e
      raise XMLParseError
    end
    
    begin
    non_xml_to_xml_from_xml_to_non_xml =
      @xsugar.non_xml_to_xml(xml_to_non_xml)
    rescue NativeException => e
      raise NonXMLParseError
    end
    
    assert_equal ab(lb(expected)), non_xml_to_xml_from_xml_to_non_xml
    return xml_to_non_xml
  end
  
  def transform_xml_fragment_to_non_xml(input)
    xml_to_non_xml = @xsugar.xml_to_non_xml(ab(lb(input)))
  end
end