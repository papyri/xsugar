#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), *%w"lib xsugar")

if ARGV.length != 2
  puts "Usage: #{$0} grammar.xsg input.xml > output.txt"
  Process.exit
end

grammar_file = ARGV[0]
xml_file = ARGV[1]
xsg = File.readlines(grammar_file).to_s
@xsugar = RXSugar.new(xsg)

xml_content = File.readlines(xml_file).to_s

puts @xsugar.xml_to_non_xml(xml_content)