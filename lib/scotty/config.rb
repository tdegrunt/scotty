require "yaml"

module Scotty
  class Config

    class << self
      def config
        @@config ||= YAML::load_file("#{File.dirname(__FILE__)}/../../config/config.yml")
      end
      def fog
        config[:fog]
      end
    end
  end
end
