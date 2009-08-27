require 'test/unit'

module GrammarAssertions
  class ParseError < ::StandardError; end
  class XMLParseError < ParseError; end
  class NonXMLParseError < ParseError; end
  
  include Test::Unit::Assertions
  
  def ab(xml)
  # added wrapab tags to match new grammar for multiple ab sections
  # changed wrapab to div edition tags with div textpart for new requirements of processing tags outside ab section
    #return "<wrapab><ab>#{xml}</ab></wrapab>"
	#return "<div lang=\"grc\" type=\"edition\"><div n=\"Fr1\" type=\"textpart\"><ab>#{xml}</ab></div></div>" worked
	return "<wrapab><div n=\"Fr1\" type=\"textpart\"><ab>#{xml}</ab></div></wrapab>"
  end
  
  def lab(notxml)
  # added to wrap in leiden syntax to match new grammar for multiple ab sections
  # added <D=.Fr1 .... =D> for new div textpart
    return "<D=.Fr1 <=#{notxml}=>=D>"
  end

  def lb(xmlline)
    return "<lb n=\"1\"/>#{xmlline}"
	#return "<lb n=\"1\"></lb>#{xmlline}"
  end

  def assert_equal_fragment_transform(non_xml_fragment, xml_fragment)
    non_xml_fragment = "1. #{non_xml_fragment}"
	non_xml_fragment = lab(non_xml_fragment)
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