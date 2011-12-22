module Scotty
  class Component
    attr_accessor :name, :path, :config_proc, :install_proc, :configure_proc, :configure_group_proc, :remove_proc, :test_proc

    class << self
      def load(name)
        Component::DSL.load(name)
      end
    end
  end
end
