require 'redis'

require "dconfig/railtie" if defined? Rails

module Dconfig
  extend self

  attr_accessor :key
  @key = "dconfig"

  # Accepts:
  #   1. A 'hostname:port' String
  #   2. A 'hostname:port:db' String (to select the Redis db)
  #   3. A Redis URL String 'redis://host:port'
  #   4. An instance of `Redis`, `Redis::Client`, `Redis::DistRedis`,
  #      or `Redis::Namespace`.
  def redis=(server)
    if server.is_a? String
      if server =~ /redis\:\/\//
        @redis = Redis.connect(:url => server, :thread_safe => true)
      else
        host, port, db = server.split(':')
        @redis = Redis.new(:host => host, :port => port,
                          :thread_safe => true, :db => db)
      end
    else
      @redis = server
    end
  end

  def redis
    return @redis if @redis
    self.redis = Redis.respond_to?(:connect) ? Redis.connect : "localhost:6379"
    self.redis
  end

  def add_missing_fields(hash)
    hash.each do |field, value|
      redis.hsetnx @key, field, value
    end
  end

  def get_all
    redis.hgetall(@key)
  end

  def has_key?(field)
    @redis.hexists @key, field
  end

  def set(field, value)
    @redis.hset @key, field, value
  end

  def mset(hash)
    @redis.hmset @key, *hash.flatten
  end

  def get(field)
    @redis.hget @key, field
  end

  def mget(*fields)
    {}.tap do |r|
      @redis.hmget(@key, *fields).each_with_index do |value, index|
        r[fields[index]] = value
      end
    end
  end

  def set_boolean(field, value)
    set(field, value ? 1 : 0)
  end

  def get_boolean(field)
    value = @redis.hget(@key, field)
    value.nil? ? false : value != '0'
  end


  def delete(field)
    @redis.hdel @key, field
  end

  def method_missing(method, *args, &block)
    return self.send method, *args, &block if self.respond_to? method
    method_name = method.to_s

    if method_name =~ /=$/
      return self.set method_name.sub(/=$/, ""), args.first
    else
      return self.get method_name
    end
  end
end
