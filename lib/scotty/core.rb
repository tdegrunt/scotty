module Scotty
  class Core
    attr_accessor :provider

    def initialize
      Fog.credentials = Scotty::Config.fog[:credentials]
      @provider = Fog::Compute.new(Scotty::Config.fog[:compute])
    end

    def servers
      @servers ||= Scotty::Servers.new(:provider => provider)
    end

    def components
      Scotty::Components.instance
    end


  end
end
