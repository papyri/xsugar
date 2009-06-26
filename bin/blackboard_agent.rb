#!/usr/bin/env jruby
require 'drb/drb'
require 'rinda/rinda'
require 'rinda/ring'

require File.join(File.dirname(__FILE__), *%w'.. lib jruby_helper')
require File.join(File.dirname(__FILE__), *%w'.. lib rxsugar')

include RXSugar::RXSugarHelper

DRb.start_service
# Just use the primary service, change this if we're going to register
# any more services on the Ring Server
ring_server = Rinda::RingFinger.primary

tuplespace = ring_server.read([:name, :TupleSpace, nil, nil])[2]
tuplespace = Rinda::TupleSpaceProxy.new tuplespace

# set up the constants we'll reuse inside the loop
rxsugar = rxsugar_from_grammar(DEFAULT_GRAMMAR)
loop do
  from, to, content, object_id = tuplespace.take([%r{^(?:xml|nonxml)$},
                                                  %r{^(?:xml|nonxml)$},
                                                  String, Fixnum])
  begin
    if from == 'xml' && to == 'nonxml'
      transformed = rxsugar.xml_to_non_xml(content).to_s
    elsif from == 'nonxml' && to == 'xml'
      transformed = rxsugar.non_xml_to_xml(content).to_s
    end
    result_type = :ok
  rescue NativeException => e
    result_type = :exception
    transformed = e.cause.to_s
  end
  
  tuplespace.write([:result, object_id, result_type, transformed])
end