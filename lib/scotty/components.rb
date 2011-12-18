require "singleton"

module Scotty
  class Components < Hash
    include Singleton

    def initialize
      super
      puts "#{File.dirname(__FILE__)}/components/*"
      Dir["#{File.dirname(__FILE__)}/components/*"].each do |file|
        file = file.split("/").last
        component = Scotty::Component.load(file)
        component.provides.each do |item|
           store(item, component)
        end
      end
    end
  end
end
