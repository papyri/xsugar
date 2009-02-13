#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), *%w"lib xsugar")

non_xml_file = STDIN
grammar_file = RXSugarHelper::DEFAULT_GRAMMAR

if ARGV.length >= 1 && ARGV[0] == '--help'
  puts "Usage: #{$0} < input.txt > output.xml\n" +
       "       #{$0} grammar.xsg < input.txt > output.xml\n" +
       "       #{$0} grammar.xsg input.txt > output.xml"
  Process.exit
end

if ARGV.length >= 1
  grammar_file = ARGV[0]
  if ARGV.length >= 2
    non_xml_file = ARGV[1]
  end
end

RXSugarHelper.non_xml_file_to_xml(non_xml_file, grammar_file)