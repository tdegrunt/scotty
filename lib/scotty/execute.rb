module Scotty
  class Execute
    attr_accessor :server, :role, :component

    def initialize(attributes)
      @server = attributes[:server]
      @role = attributes[:role]
      @component = attributes[:component]
    end

    def install()
      unless test
        puts "Installing #{component.name}"
        eval_with_config component.install_proc
        raise "Failed installing #{component.name}" if !test
      end
    end

    def configure
      puts "Configuring #{component.name}"
      eval_with_config component.configure_proc
    end

    def configure_group
      eval_with_config component.configure_group_proc
    end

    def test
      eval_with_config component.test_proc
    end

    def remove
      puts "Removing #{component.name}"
      eval_with_config component.remove_proc
      raise "Failed removing #{component.name}" if test
    end

    private

    def with_server(other_server)
      current_server = server
      @server = other_server
      yield
      @server = current_server
    end

    def path
      component.path
    end

    def exec(script)
      puts "#{server.name}: exec '#{script}'"
      [*script].map do |line|
        server.ssh(line.gsub("\n", " ; ")).last
      end.last
    end

    def copy(file_name, remote_file = nil)
      puts "#{server.name}: copy: '#{file_name}'"
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

    def servers
      Scotty::Core.instance.servers
    end

    def nodes
      servers.role(role)
    end

    def template_binding
      ErbTemplateBinding.new(:config => configatron, :servers => servers, :nodes => nodes, :roles => Scotty::Core.instance.roles).get_binding
    end

    def config
      configatron
    end

    def eval_with_config(block)
      configatron.temp do
        instance_eval(&component.config_proc) if component.config_proc
        instance_eval(&block) if block
      end
    end
  end
end
