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
          @components[component_path.split("/").last.to_sym] = component
        end
      end
      @components
    end

    def servers
      Scotty::Core.instance.servers.role(self)
    end

    def add_server(options = {})
      server = with_config do
        Scotty::Core.instance.servers.create(options)
      end
      server.ssh "echo #{name} > .role"
      install(:server => server)
      server
    end

    def install(options = {})
      execute(:install, options)
    end

    def test(options = {})
      execute(:test, options)
    end

    def configure(options = {})
      execute(:configure, options)
    end

    def configure_group(options = {})
      execute(:configure_group, options)
    end

    def remove(options = {})
      execute(:remove, options)
    end

    private

    def execute(action, options = {})
      options[:server] ||= servers
      options[:component] ||= components

      results = []

      with_config do
        [*action].each do |action|
          [*options[:server]].each do |server|
            [*options[:component]].each do |component|
              component = component[1] if component.is_a?(Array)
              component = components[component] if component.is_a?(Symbol)

              results << Scotty::Execute.new(:server => server, :role => self, :component => component).send(action.to_sym)
            end
          end
        end
      end
      results
    end

    def with_config
      configatron.temp do
        def config
          configatron
        end
        instance_eval File.open("#{path}/config.rb").read
        yield
      end
    end

    def path
      "#{File.dirname(__FILE__)}/../../data/roles/#{name}"
    end
  end
end
