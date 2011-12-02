require 'yaml'
require 'erb'

DCONFIG_PATH = "#{File.dirname(__FILE__)}/dconfig"
require "#{DCONFIG_PATH}/railtie.rb"

module Dconfig
  class << self
    def setup!

    end
  end
end
