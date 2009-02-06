#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), *%w"lib xsugar")

if ARGV.length != 2
  puts "Usage: #{$0} grammar.xsg input.txt > output.xml"
  Process.exit
end

grammar_file = ARGV[0]
text_file = ARGV[1]
xsg = File.readlines(grammar_file).to_s
@xsugar = RXSugar.new(xsg)

text_content = File.readlines(text_file).to_s

puts @xsugar.non_xml_to_xml(text_content)