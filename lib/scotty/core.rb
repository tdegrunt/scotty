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

    def roles
      unless @roles
        @roles = {}
        Dir["#{File.dirname(__FILE__)}/../../data/roles/*"].each do |role|
          role = role.split('/').last
          @roles[role.to_sym] = Scotty::Role.new(:name => role)
        end
      end
      @roles
    end

    def components
      @components ||= Scotty::Components.new
    end

    def reload!
      @server = nil
      @roles = nil
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
