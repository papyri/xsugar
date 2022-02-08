# encoding: utf-8
require 'test/unit'
require 'rexml/document'

module GrammarAssertions
  include Test::Unit::Assertions
  
  def ab(xml)
  # added wrapab tags to match new grammar for multiple ab sections
  # added <div  type=textpart
  #change wrapab to div editon to match new grammar to handle language on div edition
    return "<div xml:lang=\"grc\" type=\"edition\" xml:space=\"preserve\" xmlns:xml=\"http://www.w3.org/XML/1998/namespace\"><div n=\"Fr1\" type=\"textpart\"><ab>#{xml}</ab></div></div>"
  end
  
  def lab(notxml)
  # added <=.... => to wrap in leiden syntax to match new grammar for multiple ab sections
  # added <D=.Fr1 .... =D> for new div textpart
  #added <S=.grc to match new grammar to handle language on div edition
    return "<S=.grc<D=.Fr1<=#{notxml}=>=D>"
  end

  def lb(xmlline)
    return "<lb n=\"1\"/>#{xmlline}"
  end

  def assert_equal_fragment_transform(non_xml_fragment, xml_fragment)
    non_xml_fragment = "1. #{non_xml_fragment}"
    non_xml_fragment = lab(non_xml_fragment)
    non_xml_fragment = RXSugar::RXSugar.nfd(non_xml_fragment)
    xml_fragment = RXSugar::RXSugar.nfc(xml_fragment)
    # non-xml -> xml equal
    assert_equal ab(lb(xml_fragment)), @xsugar.non_xml_to_xml(non_xml_fragment)
    # xml -> non-xml equal
    assert_equal non_xml_fragment, @xsugar.xml_to_non_xml(ab(lb(xml_fragment)))
    # non-xml -> xml -> non-xml equal
    assert_equal_non_xml_to_xml_to_non_xml non_xml_fragment, non_xml_fragment
    # xml -> non-xml -> xml equal
    assert_equal_xml_fragment_to_non_xml_to_xml_fragment xml_fragment, xml_fragment
  end
  
  def assert_equal_non_xml_to_xml_to_non_xml(expected, input)
    assert_equal expected, @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml(input))
  end
  
  def get_attrib_text_node(xmlin, attribsback, textback, nodesback)
    
    #wrap it to keep away from 'adding second root' error 
    wrapxml = "<wrapab>" + xmlin + "</wrapab>"
    workxml = REXML::Document.new(wrapxml)

    workxml.elements['wrapab'].each do |z|
      if z.node_type.to_s == "element"
        #add node name to array for equal comparison
        nodesback << z.name
        
        #put attributes in hash for equal comparison
        #using hash with key as name+value so same attributes with different values show as separate entries in hash
        #ex. reason=lost, reason=illegible
        z.attributes.each do |name, value|
          attribsback.store("#{name+value}","#{name}")
        end
        
        z.each do |y|
          if y.node_type.to_s == "element"
            #recursive call when another tag nested inside
            get_attrib_text_node(y.to_s, attribsback, textback, nodesback)
          else
            #add text value to array for equal comparison
            textback << y.value
          end #if y element
        end #z.each
      else
        textback << z.value
      end #if z element
    end #wrapab each do
    
    return
  end

  def assert_equal_xml_fragment_to_non_xml_to_xml_fragment(expected, input)
    #convert input xml to Leiden+
    begin
      xml_to_non_xml = RXSugar::RXSugar.nfd(@xsugar.xml_to_non_xml(RXSugar::RXSugar.nfc(ab(lb(input)))))
    rescue Encoding::CompatibilityError, NativeException => e
      raise RXSugar::XMLParseError
    end
    #convert Leiden+ from above back to XML for comparison to expected XML to see if they match
    begin
    non_xml_to_xml_from_xml_to_non_xml =
      RXSugar::RXSugar.nfc(@xsugar.non_xml_to_xml(RXSugar::RXSugar.nfd(xml_to_non_xml)))
    rescue Encoding::CompatibilityError, NativeException => e
      raise RXSugar::NonXMLParseError
    end
    
    #not sure if this the best way to compare the 2 sets of XML and match regardless of attrib order but it seems to work
    
    #parse the 'expected' XML passed in into attributes, text values, and node names
   
    begin 
    if expected.include?("</ab><ab>")
      #jump through a lot of hoops to make multiple ab section test case work - may pull out
      tempab = ab(expected)
      #remove namespace or REXML barfs in Linux
      tempab.sub!(/ xmlns:xml="http:\/\/www.w3.org\/XML\/1998\/namespace"/,'')
      startexpected = REXML::Document.new(tempab)
      expectedinsideab = REXML::XPath.match(startexpected, 'div/div/ab/node()')
      #wrap it to keep away from 'adding second root' error
      tempexpected = "<wrapab>" + expectedinsideab.join('') + "</wrapab>"
      finalexpected = REXML::Document.new(tempexpected)
    else
      tempexpected = "<wrapab>" + expected + "</wrapab>"
      finalexpected = REXML::Document.new(tempexpected)
    end
    
    compare_expected_attribs = Hash.new
    compare_expected_text = Array.new
    compare_expected_nodes = Array.new
    
    finalexpected.elements['wrapab'].each do |z|
      #call function to parse expected XML passing the XML, hash for attribs, array for text, and array for nodes
      get_attrib_text_node(z.to_s, compare_expected_attribs, compare_expected_text, compare_expected_nodes)
    end #wrapab do
    
    #parse the XML created by taking the 'input' XML and converting to Leiden+ and then back to XML
    #this is where the attribute order can change from the 'expected' and why the extra is in 
    
    #jump through a lot of hoops to get all nodes from inside the ab tag
    #remove namespace or REXML barfs in Linux
    non_xml_to_xml_from_xml_to_non_xml.sub!(/ xmlns:xml="http:\/\/www.w3.org\/XML\/1998\/namespace"/,'')
    startinput = REXML::Document.new(non_xml_to_xml_from_xml_to_non_xml)
    #only comparing the XML inside the ab tag - node() will pull text nodes and element nodes
    inputinsideab = REXML::XPath.match(startinput, 'div/div/ab/node()')
    #remove line number tag added during Xsugar transformation process that is not needed
    tempinput = inputinsideab.nil? ? "" : inputinsideab.join('').sub!(/<lb n='1'\/>/, "")
    #wrap it to keep away from 'adding second root' error
    tempinput = "<wrapab>" + (tempinput || "") + "</wrapab>"
    finalinput = REXML::Document.new(tempinput)
    
    compare_input_attribs = Hash.new
    compare_input_text = Array.new
    compare_input_nodes = Array.new
    
    finalinput.elements['wrapab'].each do |z|
      #call function to parse input XML passing the XML, hash for attribs, array for text, and array for nodes
      get_attrib_text_node(z.to_s, compare_input_attribs, compare_input_text, compare_input_nodes)
    end
    
    #assert equal the attribs hash, text array, and nodes array created from expected and input XML are equal
    #sort the attribs hash so the attribute order does not matter - everything else should be the same
    assert_equal compare_expected_text+compare_expected_nodes+compare_expected_attribs.sort, compare_input_text+compare_input_nodes+compare_input_attribs.sort
    rescue Encoding::CompatibilityError, TypeError => e
      raise RXSugar::XMLParseError
    end
    return xml_to_non_xml
  end
  
  def transform_xml_fragment_to_non_xml(input)
    xml_to_non_xml = @xsugar.xml_to_non_xml(ab(lb(input)))
    return xml_to_non_xml
  end

  def transform_non_xml_fragment_to_xml(input)
    return @xsugar.non_xml_to_xml(lab(input))
  end

  def transform_non_xml_to_xml(input)
    return @xsugar.non_xml_to_xml(input)
  end

  def transform_xml_to_non_xml(input)
    return @xsugar.xml_to_non_xml(input)
  end

  def assert_equal_edition_roundtrip(input)
    xml = @xsugar.non_xml_to_xml(input)
    nonxml = @xsugar.xml_to_non_xml(xml)
    assert_equal(input, nonxml)
  end

end
