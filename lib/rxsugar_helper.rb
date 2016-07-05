require 'rexml/document'

module RXSugar
  module RXSugarHelper
    XSUGAR_JAR_PATH = File.join(File.dirname(__FILE__), *%w".. lib xsugar-all.jar")
    DEFAULT_GRAMMAR = File.join(File.dirname(__FILE__), *%w".. epidoc.xsg")
    TRANSLATION_GRAMMAR = File.join(File.dirname(__FILE__), *%w".. translation_epidoc.xsg")
    COMMENTARY_GRAMMAR = File.join(File.dirname(__FILE__), *%w".. commentary.xsg")

    def rxsugar_from_grammar(grammar_file = DEFAULT_GRAMMAR)
      xsg = File.readlines(grammar_file).join('')
      RXSugar.new(xsg)
    end

    def xml_file_to_non_xml(xml_file = STDIN, grammar_file = DEFAULT_GRAMMAR, output = STDOUT)
      rxsugar = rxsugar_from_grammar(grammar_file)
      if xml_file.class == IO
        xml_content = xml_file.readlines.to_s
      else
        xml_content = IO.readlines(xml_file).to_s
      end
      
      begin
        output.puts rxsugar.xml_to_non_xml(xml_content)
      rescue NativeException => e
        output.puts e.cause
      end
    end
  
    def non_xml_file_to_xml(non_xml_file = STDIN, grammar_file = DEFAULT_GRAMMAR, output = STDOUT)
      rxsugar = rxsugar_from_grammar(grammar_file)
      if non_xml_file.class == IO
        non_xml_content = non_xml_file.readlines.to_s
      else
        non_xml_content = IO.readlines(non_xml_file).to_s
      end
      
      begin
        output.puts rxsugar.non_xml_to_xml(non_xml_content)
      rescue NativeException => e
        output.puts e.cause
      end
    end
    
    def collapse_nodes_to_single_line(nodes)
      processed = ''
      nodes.each do |node|
        node.to_s.each_line do |line|
          processed += line.chomp.strip
        end
      end
      processed
    end
    
    def identifying_string_from_element(rexml)
      identifier = rexml.name
      rexml.attributes.each do |name, value|
        identifier += " " + name + "=\"#{value}\""
      end
      identifier
    end
    
    def get_non_empty_element_children(rexml)
      REXML::XPath.match(rexml, '*[node()]')
    end
    
    def get_non_lb_element_children(rexml)
      #REXML::XPath.match(rexml, '*[not(self::lb)]')
      REXML::XPath.match(rexml, './div/ab/*[not(self::lb)]|./ab/*[not(self::lb)]')
    end
	
    def get_all_element_children(rexml)
      REXML::XPath.match(rexml, './div/ab/*|./ab/*')
    end
  end
end
