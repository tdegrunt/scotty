require "scotty/version"
require "scotty/config"
require "scotty/servers"
require "scotty/component"
require "scotty/component_dsl"
require "scotty/core"

module Scotty

  class Init
    def self.reload!
      path = File.dirname(__FILE__) + "/"
      load path + "scotty.rb"
      load path + "scotty/config.rb"
      load path + "scotty/servers.rb"
      load path + "scotty/component.rb"
      load path + "scotty/component_dsl.rb"
      load path + "scotty/core.rb"
    end
  end
end
