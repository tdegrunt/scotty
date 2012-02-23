module Scotty

  class HashArray < Array
    def [](*args)
      if args.size == 1 && (args.first.is_a?(Hash))
        key, value = args.first.first
        find{|item| item.respond_to?(key) && item.send(key) == value}
      else
        super
      end
    end
  end


  class Core
    include Singleton

    attr_accessor :provider, :config_proc

    def initialize
      EnvironmentDsl.load(self, "/data/dev/scotty/data/scotty.rb")
      Fog.credentials = configatron.fog.credentials.to_hash
    end

    def roles
      @roles ||= HashArray.new
    end

    def servers
      @servers ||= Scotty::Servers.new
    end

    def reload!
      @servers = nil
      initialize
    end
  end
end

# HACKS

class Configatron::Store
  def to_s
    ""
  end
end
