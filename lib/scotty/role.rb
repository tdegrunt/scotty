module Scotty
  class Role
    attr_accessor :name, :components

    def initialize(attributes = {})
      @name = attributes[:name]
    end

    def servers
      Scotty::Core.instance.servers.role(self)
    end

    def add_server(options = {})
      server = with_config do
        Scotty::Core.instance.servers.create(options)
      end
      server.ssh "echo #{name} > .role"
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
      options[:server] ||= servers.first
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
              results << Scotty::Execute.new(:server => server, :role => self, :component => component).send(action.to_sym)
            end
          end
        end
      end
      results
    end
  end
end
