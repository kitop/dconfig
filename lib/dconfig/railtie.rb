require 'railtie'
require 'dconfig'

module Dconfig
  class Railtie < Rails::Railtie
    config.before_configuration do
      Dconfig.setup!
    end
  end
end
