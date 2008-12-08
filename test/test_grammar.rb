require 'test_helper'

class GrammarTest < Test::Unit::TestCase
  def test_stub
    # epidoc_txt = File.join(File.dirname(__FILE__), *%w".. epidoc.txt")
    # epidoc_content = File.readlines(epidoc_txt).to_s
    # puts epidoc_content
    # puts non_xml_to_xml(epidoc_content)
    puts @xsugar.non_xml_to_xml("test\n")
    puts @xsugar.non_xml_to_xml("test\ntest2\n")
    puts ab("test")
    puts @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test\n"))
    assert_equal "test", @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test"))
    assert_equal "test1\ntest2", @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test1\ntest2"))
  end
  
  def test_xml_trailing_newline_stripped
    assert_equal "test", @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test\n"))
    assert_equal "test1\ntest2", @xsugar.xml_to_non_xml(@xsugar.non_xml_to_xml("test1\ntest2\n"))
  end
end