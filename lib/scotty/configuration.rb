module Scotty

  class Binding
    attr_accessor :config, :servers

    def initialize(attributes = {})
      @config = attributes[:config]
      @servers = attributes[:servers]
    end

    def get_binding
      binding
    end
  end

  class Configuration

    def name
      @name ||= "#{Time.now.strftime("%Y%m%d%H%M")}"
    end

    def generate
      #FIXME: Refactor this HORRIBLE code

      Dir["#{roles_directory}/*"].each do |role_directory|
        role = role_directory.split("/").last
        Dir["#{role_directory}/**/*"].each do |file|
          unless File.directory?(file)
            template = File.open(file).read
            file_name = file.gsub(role_directory, "")

            if file_name.split('.').last == "erb"
              file_name = file_name.gsub(".erb", "")
              template = ERB.new(template, 0, "%<>").result(template_binding)
            end

            directory = file_name.split("/")
            directory.pop
            directory = directory.join("/")
            `mkdir -p #{configuration_directory}/#{role}/#{directory}`

            File.open("#{configuration_directory}/#{role}/#{file_name}", "w") do |f|
              f.write template
            end
          end
        end
      end
    end

    private

    def template_binding
      @binding ||= Binding.new(:config => configatron, :servers => Scotty::Core.instance.servers)
      @binding.get_binding
    end

    def roles_directory
      "#{File.dirname(__FILE__)}/../../data/roles"
    end

    def configuration_directory
      "#{File.dirname(__FILE__)}/../../data/configurations/#{name}"
    end

  end
end
