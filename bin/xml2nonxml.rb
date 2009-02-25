#!/usr/bin/env jruby
require File.join(File.dirname(__FILE__), *%w'.. lib util_helper')

RXSugar::UtilHelper.new('xml', 'txt').main