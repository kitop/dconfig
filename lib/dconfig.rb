require 'yaml'
require 'erb'
require 'redis'

DCONFIG_PATH = "#{File.dirname(__FILE__)}/dconfig"
require "#{DCONFIG_PATH}/railtie.rb"

module Dconfig
  class UndefinedDconfig < StandardError; end
  class << self
    def setup!
      yml = get_yml
      redis = get_redis
      create_dconfig_class(yml)
    end

    def get_yml
      "#{Rails.root.to_s}/config/dconfig.yml"
    end

    def get_redis
      config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
      Redis.new(:host => config['host'], :port => config['port'])
    end

    def load_yml(yml_file)
      erb = ERB.new(File.read(yml_file)).result
      hash = YAML.load(erb).to_hash[Rails.env]
      klass = Object.const_set('DConfig', Class.new)
      hash.each do |key,value|
        klass.define_singleton_method(key){ value }
      end
      klass.class_eval do
        def self.method_missing(method_id,*args)
          raise UndefinedDconfig, "#{method_id} is not defined in #{self.to_s}"
        end
      end
    end

    def create_dconfig_class(yml_file)
      hash = load_yml(yml_file)
    end
  end # class << self
end
