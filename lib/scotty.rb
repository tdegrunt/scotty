require "erb"
require "fog"
require "singleton"
require "configatron"

require "data/config.rb"

require "scotty/version"
require "scotty/server"
require "scotty/servers"
require "scotty/component"
require "scotty/component_dsl"
require "scotty/components"
require "scotty/configuration"
require "scotty/core"

module Scotty
  class Init
    def self.reload!
      path = File.dirname(__FILE__) + "/"
      load path + "../data/config.rb"
      load path + "scotty.rb"
      load path + "scotty/server.rb"
      load path + "scotty/servers.rb"
      load path + "scotty/component.rb"
      load path + "scotty/component_dsl.rb"
      load path + "scotty/components.rb"
      load path + "scotty/configuration.rb"
      load path + "scotty/core.rb"
    end
  end
end
