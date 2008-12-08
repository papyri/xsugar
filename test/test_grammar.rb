require 'test_helper'

class GrammarTest < Test::Unit::TestCase
  def test_stub
    # epidoc_txt = File.join(File.dirname(__FILE__), *%w".. epidoc.txt")
    # epidoc_content = File.readlines(epidoc_txt).to_s
    # puts epidoc_content
    # puts non_xml_to_xml(epidoc_content)
    puts non_xml_to_xml("test\n")
    puts xml_to_non_xml(non_xml_to_xml("test\n"))
    assert_equal "test\n", xml_to_non_xml(non_xml_to_xml("test\n"))
  end
end