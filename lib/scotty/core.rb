module Scotty
  class Core
    include Singleton

    attr_accessor :provider

    def initialize
      Fog.credentials = configatron.fog.credentials.to_hash
    end

    def servers
      @servers ||= Scotty::Servers.new
    end

    def components
      @components ||= Scotty::Components.new
    end

    def reload!
      @server = nil
      @components = nil
    end

  end
end

# HACKS

class Configatron::Store
  def to_s
    ""
  end
end
