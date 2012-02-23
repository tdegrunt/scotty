require "erb"
require "fog"
require "singleton"
require "configatron"

require "scotty/version"
require "scotty/erb_template_binding"
require "scotty/server"
require "scotty/servers"
require "scotty/component"
require "scotty/component_dsl"
require "scotty/role"
require "scotty/execute"
require "scotty/environment_dsl"
require "scotty/core"

module Scotty
  class Init
    def self.reload!
      path = File.dirname(__FILE__) + "/"
      load path + "scotty.rb"
      load path + "scotty/erb_template_binding.rb"
      load path + "scotty/server.rb"
      load path + "scotty/servers.rb"
      load path + "scotty/component.rb"
      load path + "scotty/component_dsl.rb"
      load path + "scotty/role.rb"
      load path + "scotty/execute.rb"
      load path + "scotty/environment_dsl.rb"
      load path + "scotty/core.rb"
      Scotty::Core.instance.reload!
      Scotty::Core.instance.servers.refresh
    end
  end
end
