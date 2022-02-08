#!/usr/bin/env ruby -i
require File.join(File.dirname(__FILE__),'lib','rxsugar')

ARGF.each_line do |e|
  puts RXSugar::RXSugar.nfc(e)
end