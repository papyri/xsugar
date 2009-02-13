#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), *%w"lib xsugar")

xml_file = STDIN
grammar_file = RXSugarHelper::DEFAULT_GRAMMAR

if ARGV.length >= 1 && ARGV[0] == '--help'
  puts "Usage: #{$0} < input.xml > output.txt\n" +
       "       #{$0} grammar.xsg < input.xml > output.txt\n" +
       "       #{$0} grammar.xsg input.xml > output.txt"
  Process.exit
end

if ARGV.length >= 1
  grammar_file = ARGV[0]
  if ARGV.length >= 2
    xml_file = ARGV[1]
  end
end

RXSugarHelper.xml_file_to_non_xml(xml_file, grammar_file)