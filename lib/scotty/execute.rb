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
        log "installing #{component.name}"
        eval_with_config component.install_proc
        raise "Failed installing #{component.name}" if !test
      end
      true
    end

    def configure
      log "configuring #{component.name}"
      eval_with_config component.configure_proc
      true
    end

    def configure_group
      eval_with_config component.configure_group_proc
      true
    end

    def test
      eval_with_config component.test_proc
    end

    def remove
      log "removing #{component.name}"
      eval_with_config component.remove_proc
      raise "Failed removing #{component.name}" if test
      true
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
      log "exec '#{cd} #{script}'"
      [*script].map do |line|
        server.ssh(line.gsub("\n", " ; ")).last
      end.last
    end

    def copy(file_name, remote_file = nil, options = {})
      log "copy '#{file_name}'"

      remote_file = "#{home_directory}/#{remote_file}" unless !home_directory || (remote_file && remote_file[0] == "/")

      local_file = case
        when File.exists?("#{path}/#{file_name}.#{role}.erb")
          "#{path}/#{file_name}.#{role}.erb"
        when File.exists?("#{path}/#{file_name}.#{role}")
          "#{path}/#{file_name}.#{role}"
        when File.exists?("#{path}/#{file_name}.erb")
          "#{path}/#{file_name}.erb"
        when File.exists?("#{path}/#{file_name}")
          "#{path}/#{file_name}"
        else
          raise "Cannot open file #{file_name}"
      end

      if local_file.split('.').last == "erb"
        parsed_file = "#{local_file}.parsed"

        File.open(parsed_file, "w") do |file|
          file.write(ERB.new(File.open(local_file).read, 0, "%<>").result(template_binding))
        end

        server.scp(parsed_file, (remote_file || file_name), options)
        File.delete(parsed_file)
      else
        server.scp(local_file, (remote_file || file_name), options)
      end
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

    def home_directory(dir = nil)
      @home_directory = dir if dir
      @home_directory
    end

    def cd
      "cd #{@home_directory} ; " if @home_directory
    end

    def eval_with_config(block)
      configatron.temp do
        instance_eval(&Scotty::Core.instance.config_proc) if Scotty::Core.instance.config_proc
        instance_eval(&block) if block
      end
    end

    def log(message)
      puts "#{server.name}: #{message}"
    end
  end
end
