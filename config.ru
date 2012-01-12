#!/usr/bin/env ruby
require 'logger'

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'dconfig/server'

use Rack::ShowExceptions
run Dconfig::Server.new

