require 'yaml'
require 'erb'

module Dconfig
  class Railtie < Rails::Railtie
    config.before_configuration do
      redis_file = File.join(Rails.root, "config", "redis.yml")
      if File.exists? config_file
        config = load_yml(redis_file)
        if config.is_a? String
          Dconfig.redis = config
        else
          Dconfig.redis = Redis.new(host: config['host'], port: config['port'], password: config['password'], thread_safe: true, db: (config['db'] || 0 ))
        end
      end

      base_keys_file = File.join(Rails.root.to_s, "config", "dconfig.yml")
      if File.exists? base_key_file
        base_keys = load_yml(redis_file)

        Dconfig.add_missing_fields(base_keys)
      end

      #namespace the key
      Dconfig.key = Rails.application.class.to_s.split("::").first + ":dconfig"
    end
  end

  def load_yml(yml_file)
    erb = ERB.new(File.read(yml_file)).result
    YAML.load(erb).to_hash[Rails.env]
  end

end
