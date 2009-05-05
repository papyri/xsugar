#!/usr/bin/env jruby
require 'drb/drb'
require 'rinda/tuplespace'
require File.join(File.dirname(__FILE__), *%w'.. lib jruby_helper')

DRb.start_service(RXSugar::JRubyHelper::DRB_SERVER_URI, Rinda::TupleSpace.new)
DRb.thread.join