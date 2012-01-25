Dconfig
=======
Dynamic configuration settings stored on redis


Requirements
------------

* Redis installed (2.2+ recommended)
* Tested on Ruby 1.9 (why are you still on 1.8?)


Installation
-----------

    gem install dconfig


Usage
-----

Simple:
    require 'dconfig'

    #set any key
    Dconfig.your_setting = "Some value"

    #retrieve that key
    Dconfig.your_setting # => "Some Value"

    #delete that key
    Dconfig.delte "your_setting"

It also got a bunch of other methods as 

* `get(key)` Retrieves the value of a key
* `set(key, value)` Sets the value of a key
* `mget(key1, key2, key3...)` Multi get
* `mset(hash)` Multi set
* `delete(key)` Deletes a key
* `has_key?(key)` Self explanatory
* `get_all` Retrieves all the keys
* `get_boolean(key)` Gets a key converted to true or false
* `set_boolean(key, value)` Sets a key and coverts it to boolean
* `add_missing_fiels(hash)` Sets all the non-existing keys of that hash

You can also set the redis instance via `Dconfig.redis=` 
which can receive several options:

* A `hostname:port` String
* A `hostname:port:db` String (to select the Redis db)
* A Redis URL String `redis://host:port`
* An instance of `Redis`, `Redis::Client`, `Redis::DistRedis`, `Redis::Namespace`.

And you can also set the main redis key (where the hash is stored). 
By default it is *dconfig*

### Rails

Using it on rails is as simple as requiring it on your Gemfile

You can also customize some settings in an initializer, for example:

``` ruby
redis_file = File.join(Rails.root, "config", "redis.yml")
if File.exists? redis_file
  config = YAML.load(ERB.new(File.read(redis_file)).result).to_hash[Rails.env]
  if config.is_a? String
    Dconfig.redis = config
  else
    Dconfig.redis = Redis.new(host: config['host'], port: config['port'],
                              password: config['password'], thread_safe: true,
                              db: (config['db'] || 0 ))
  end
end

#namespace the key
Dconfig.key = Rails.application.class.to_s.split("::").first + ":dconfig"

base_keys_file = File.join(Rails.root.to_s, "config", "dconfig.yml")
if File.exists? base_keys_file
  base_keys = YAML.load(ERB.new(File.read(base_keys_file)).result).to_hash[Rails.env]

  Dconfig.add_missing_fields(base_keys)
end
```

There it loads redis config from a config/redis.yml file, and a set of base fields}
from a dconfig.yml file, so it can get up and running from scratch.

Front end
---------

Dconfig also comes with a little handy Sinatra front-end to check your keys,
and edit them as you need.

You simple need to require 'dconfig/server' and run it as a Rack app.

And as any rack app, it can be mounter in Rails 3 via the config/routes.rb file

``` ruby
mount Dconfig::Server.new, :at => "/dconfig"
```


Contributing
------------
1. Fork it
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch

