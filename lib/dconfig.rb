require 'yaml'
require 'erb'
require 'redis'

DCONFIG_PATH = "#{File.dirname(__FILE__)}/dconfig"

require "#{DCONFIG_PATH}/railtie.rb"

module Dconfig
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
    end
  end # class << self

  def initialize(args)
    @db  = args[:db]
    @key = args[:key]
  end

  def set(field, value)
    @db.hsetnx @key, field, value
  end

  def get(field)
    @db.hget @key, field
  end

  def delete(field)
    @db.hget @key, field
  end
end
