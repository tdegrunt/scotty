module Scotty
  class ErbTemplateBinding
    attr_accessor :config, :servers, :nodes, :roles

    def initialize(attributes = {})
      @config = attributes[:config]
      @servers = attributes[:servers]
      @nodes = attributes[:nodes]
      @roles = attributes[:roles]
    end

    def get_binding
      binding
    end
  end
end
