require "rubygems"
require "bundler"
Bundler.setup(:default)
$:.unshift File.dirname(__FILE__)
$:.unshift File.dirname(__FILE__) + "/lib"
require 'config/addon'
