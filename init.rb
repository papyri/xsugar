Require File.join(File.dirname(__FILE__), *%w'lib jruby_helper')
ActiveRecord::Base.send(:include, RXSugar::JRubyHelper)