require 'fog'

module Scotty
  class Servers

    def initialize(options = {})
      @provider = options[:provider]
    end

    # :flavor_id => 1, :image_id => 119, :name => 'myserver'
    def create(options = {})
      puts "Initializing new server"
      server = compute.servers.bootstrap(options)
      puts "Updating"
      server.ssh("aptitude update")
      server.ssh("aptitude upgrade -y")
      puts "Completed"

      server
    end

    def list
      @provider.servers
    end

    private

    def provider
      @provider
    end

  end
end
