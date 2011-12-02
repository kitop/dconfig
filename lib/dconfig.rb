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
      create_dconfig_class(yml, redis)
    end

    def get_yml
      "#{Rails.root.to_s}/config/dconfig.yml"
    end

    def app_name
      Rails.application.class.to_s.split("::").first
    end

    def get_redis
      config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
      redis = Redis.new(:host => config['host'], :port => config['port'])
      Redis::Namespace.new(app_name, :redis => redis)
    end

    def load_yml(yml_file)
      erb = ERB.new(File.read(yml_file)).result
      YAML.load(erb).to_hash[Rails.env]
    end

    def load_from_redis(redis)
      redis.hgetall('rdconfig')
    end

    def add_missed_fields_to_redis(redis, hash_yml)
      hash_yml.each do |field, value|
        redis.hsetnx 'dconfig', field, value
      end
    end

    def create_dconfig_class(yml_file, redis)
      hash_yml = load_yml(yml_file)
      hash_redis = load_from_redis(redis)

      add_missed_fields_to_redis(redis, hash_yml)

      hash_redis = load_from_redis(redis)

      klass = Object.const_set('DConfig', Class.new)

      hash_redis.each do |key,value|
        klass.define_singleton_method(key){ value }
      end
      klass.class_eval do
        def self.method_missing(method_id,*args)
          raise UndefinedDconfig, "#{method_id} is not defined in #{self.to_s}"
        end
      end
    end
  end # class << self
end
