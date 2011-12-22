module Scotty
  class Servers

    def initialize(options = {})
      @provider = Fog::Compute.new(configatron.fog.compute.to_hash)
    end

    # :flavor_id => 1, :image_id => 119, :name => 'myserver'
    def create(options = {})
      raise "Name required" unless options[:name]
      raise "Name should be unique" if all.find {|server| server.name == options[:name]}

      options = configatron.server_specification.to_hash.merge(options)

      puts "Initializing new server"
      raise options
      server = Server.new(provider.servers.bootstrap(options))
      puts "Updating"
      server.ssh("aptitude update")
      server.ssh("aptitude upgrade -y")
      puts "Completed"

      all << server
      server
    end

    def list
      @provider.servers
    end

    def [](name)
      all.find { |server| server.name == name }
    end

    def role(role)
      all.select { |server| server.role.name == role.name }
    end

    def all
      @servers || refresh
    end

    def refresh
      # FIXME: HACK, only loading server named '*test*'
      @servers = @provider.servers.select{|server| server.name =~ /test/}.map{ |server| Server.new(server) }
    end

    private

    def provider
      @provider
    end

  end
end
