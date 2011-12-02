require 'rails'
require 'dconfig'

module DCONFIG
  class Railtie < Rails::Railtie
    config.before_configuration do
      Dconfig.setup!
    end
  end
end
