#!/usr/bin/env jruby
require 'drb/drb'
require 'rinda/rinda'
require File.join(File.dirname(__FILE__), *%w'.. lib jruby_helper')
require File.join(File.dirname(__FILE__), *%w'.. lib rxsugar')

include RXSugar::RXSugarHelper

DRb.start_service
tuplespace = Rinda::TupleSpaceProxy.new(DRbObject.new(nil, 
                                        RXSugar::JRubyHelper::DRB_SERVER_URI))

# set up the constants we'll reuse inside the loop
rxsugar = rxsugar_from_grammar(DEFAULT_GRAMMAR)
loop do
  from, to, content = tuplespace.take([%r{^(?:xml|nonxml)$},
                                       %r{^(?:xml|nonxml)$},
                                       String])
  begin
    if from == 'xml' && to == 'nonxml'
      transformed = rxsugar.xml_to_non_xml(content).to_s
    elsif from == 'nonxml' && to == 'xml'
      transformed = rxsugar.non_xml_to_xml(content).to_s
    end
  rescue NativeException => e
    transformed = e.cause.to_s
  end
  
  tuplespace.write([RESULT_IDENTIFIER, transformed])
end