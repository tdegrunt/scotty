module Scotty

  class ErbTemplateBinding
    attr_accessor :config, :servers

    def initialize(attributes = {})
      @config = attributes[:config]
      @servers = attributes[:servers]
    end

    def get_binding
      binding
    end
  end

  class Component
    attr_accessor :name, :role, :path, :server, :config_proc, :install_proc, :configure_proc, :remove_proc, :test_proc

    def install
      unless test
        with_config do
          puts "Installing #{name}"
          instance_eval(&install_proc) if install_proc

          puts "Testing #{name}"
          raise "Failed installing #{name}" if !test

          puts "Finished installing #{name}"
        end
      end
    end

    def configure
      with_config do
        instance_eval(&configure_proc) 
      end if configure_proc
    end

    def remove
      puts "Removing #{name}"
      instance_eval(&remove_proc) if remove_proc

      raise "Failed removing #{name}" if test

      puts "Finished removing #{name}"
    end

    def test
      with_config do
        test_proc ? instance_eval(&test_proc) : true
      end
    end

    private

    def exec(script)
      [*script].map do |line|
        server.ssh(line.gsub("\n", " ; ")).last
      end.last
    end

    def copy(file_name, remote_file = nil)
      local_file = "#{path}/#{file_name}"

      if file_name.split('.').last == "erb"
        file_name = file_name.gsub(".erb", "")
        parsed_file = "#{local_file}.parsed"

        File.open(parsed_file, "w") do |file|
          file.write(ERB.new(File.open(local_file).read, 0, "%<>").result(template_binding))
        end
        local_file = parsed_file
      end

      server.scp(local_file, (remote_file || file_name))
    end

    def dpkg_install(package)
      exec "mkdir packages"
      copy package, "packages/#{package}"
      exec "dpkg -i packages/#{package}"
    end

    def file_exists?(file)
      exec("find #{file}").status == 0
    end

    def assert_stdout(script, check)
      !!exec(script).stdout.match(check)
    end

    def template_binding
      ErbTemplateBinding.new(:config => configatron, :servers => Scotty::Core.instance.servers).get_binding
    end

    def with_config
      configatron.temp do
        def config
          configatron
        end
        instance_eval(&config_proc) if config_proc
        yield
      end
    end

    class << self
      def load(name)
        Component::DSL.load(name)
      end
    end
  end
end
