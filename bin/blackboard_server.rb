#!/usr/bin/env jruby
require 'drb/drb'
require 'rinda/ring'
require 'rinda/tuplespace'
require File.join(File.dirname(__FILE__), *%w'.. lib jruby_helper')

DRb.start_service

# Create a TupleSpace to hold named services, and start running
# (Ring Server)
Rinda::RingServer.new Rinda::TupleSpace.new

# Create a TupleSpace to provide the Leiden+ service
ts = Rinda::TupleSpace.new

provider = Rinda::RingProvider.new :TupleSpace, ts, 'Leiden+'
provider.provide

DRb.thread.join