module Scotty
  class Role
    attr_accessor :name

    def initialize(attributes = {})
      @name = attributes[:name]
    end

    def components
      @components = {}
      Dir["#{path}/*"].map do |component_path|
        if File.directory?(component_path)
          component = Component::DSL.load(component_path)
          @components[component.name.to_sym] = component
        end
      end
      @components
    end

    def servers
      @servers = {}
      Scotty::Core.instance.servers.role(self).each do |server|
        @servers[server.name.to_sym] = server
      end
      @servers
    end

    def add_server(options = {})
      with_config do
        Scotty::Core.instance.servers.create(options)
      end
      server.ssh "echo #{name} > .role"
      install_on(server)
      server
    end

    def install
      servers.each_value do |server|
        install_on(server)
      end
    end

    def install_on(server)
      with_config do
        components.each_value do |component|
          Scotty::Execute.new(:server => server, :role => self, :component => component).install
        end
      end
    end

    def configure
      servers.each_value do |server|
        configure_on(server)
      end
      configure_group
    end

    def configure_on(server)
      with_config do
        components.each_value do |component|
          Scotty::Execute.new(:server => server, :role => self, :component => component).configure
        end
      end
    end

    def configure_group
      with_config do
        components.each_value do |component|
          Scotty::Execute.new(:server => Scotty::Core.instance.servers.role(self).first, :role => self, :component => component).configure_group
        end
      end
    end


    def remove
      servers.each_value do |server|
        remove_from(server)
      end
    end

    def remove_from(server)
      with_config do
        components.each_value do |component|
          Scotty::Execute.new(:server => server, :role => self, :component => component).remove
        end
      end
    end

    private

    def with_config
      configatron.temp do
        load "#{path}/config.rb"
        yield
      end
    end

    def path
      "#{File.dirname(__FILE__)}/../../data/roles/#{name}"
    end
  end
end
