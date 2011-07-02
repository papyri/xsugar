require 'test/unit'

module CommentaryGrammarAssertions
  include Test::Unit::Assertions
  
  def enclose_xml_fragment(xml)
    #formerly ab(xml) for transcriptions
    #need start - end for translation xml
	  return "<wrap>#{xml}</wrap>"
  end
  
  def enclose_leiden_fragment(leiden)
    #formerly lab(notxml) for transcriptions
    #need start - end for translation leiden
    return "<W#{leiden}W>"
  end



  def assert_equal_fragment_transform(non_xml_fragment, xml_fragment)
    #non_xml_fragment = "1. #{non_xml_fragment}"
	  non_xml_fragment = enclose_leiden_fragment(non_xml_fragment)
    tempxml = @xsugar.non_xml_to_xml(non_xml_fragment)
    tempxml.sub!(/ xmlns:xml="http:\/\/www.w3.org\/XML\/1998\/namespace"/,'')
    #assert_equal enclose_xml_fragment(xml_fragment), @xsugar.non_xml_to_xml(non_xml_fragment)
    assert_equal enclose_xml_fragment(xml_fragment), tempxml
    assert_equal non_xml_fragment, @xsugar.xml_to_non_xml(enclose_xml_fragment(xml_fragment))
    assert_equal_non_xml_to_xml_to_non_xml non_xml_fragment, non_xml_fragment
    assert_equal_xml_fragment_to_non_xml_to_xml_fragment xml_fragment, xml_fragment
  end
  
  def assert_equal_non_xml_to_xml_to_non_xml(expected, input)
    assert_equal expected, @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml(input))
  end

  def assert_equal_xml_fragment_to_non_xml_to_xml_fragment(expected, input)
    begin
      xml_to_non_xml = @xsugar.xml_to_non_xml(enclose_xml_fragment(input))
    rescue NativeException => e
      raise RXSugar::XMLParseError
    end
    
    begin
    non_xml_to_xml_from_xml_to_non_xml =
      @xsugar.non_xml_to_xml(xml_to_non_xml)
    non_xml_to_xml_from_xml_to_non_xml.sub!(/ xmlns:xml="http:\/\/www.w3.org\/XML\/1998\/namespace"/,'')
    rescue NativeException => e
      raise RXSugar::NonXMLParseError
    end
    
    assert_equal enclose_xml_fragment(expected), non_xml_to_xml_from_xml_to_non_xml
    return xml_to_non_xml
  end
  
  def transform_xml_fragment_to_non_xml(input)
    xml_to_non_xml = @xsugar.xml_to_non_xml(enclose_xml_fragment(input))
  end
end
