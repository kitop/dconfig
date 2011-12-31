require 'yaml'
require 'erb'
require 'redis'

DCONFIG_PATH = "#{File.dirname(__FILE__)}/dconfig"

require "#{DCONFIG_PATH}/railtie.rb"

module Dconfig
  class << self
    def setup!
      yml = get_yml
      create_dconfig_class(yml, redis)
    end

    def redis=(server)
      config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
      redis  = Redis.new(host: config['host'], port: config['port'], password: config['password'], thread_safe: true, db: (config['db'] || 0 ))
      @key   = 'dconfig'
      @redis = Redis::Namespace.new(config['namespace'] || app_name, :redis => redis)
    end

    def redis
      return @redis if @redis
      self.redis = Redis.respond_to?(:connect) ? Redis.connect : "localhost:6379"
      self.redis
    end


    def get_yml
      "#{Rails.root.to_s}/config/dconfig.yml"
    end

    def app_name
      Rails.application.class.to_s.split("::").first
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
      hash_yml   = load_yml(yml_file)
      hash_redis = load_from_redis(redis)

      add_missed_fields_to_redis(redis, hash_yml)

      hash_redis = load_from_redis(redis)
    end

    def set(field, value)
      @redis.hset @key, field, value
    end

    def get(field)
      @redis.hget @key, field
    end

    def get_boolean(field)
      @redis.hget(@key, field) != '0'
    end

    def delete(field)
      @redis.hdel @key, field
    end

    def method_missing(method, *args, &block)
      return self.send method, *args, &block if self.respond_to? method
      method_name = method.to_s

      if method_name =~ /=/
        return self.set method_name.gsub("=", ""), args.first
      else
        return self.get method_name
      end
    end
  end # class << self
end
