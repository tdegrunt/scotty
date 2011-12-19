module Scotty
  class Component
    attr_accessor :name, :server, :requires, :provides, :install_proc, :remove_proc, :detect_files, :test_proc

    def install_dependencies
      puts "Installing dependencies"
      raise "Not implemented" if requires
    end

    def install
      unless test
        install_dependencies

        puts "Installing #{name}"
        instance_eval &install_proc

        puts "Testing #{name}"
        raise "Failed installing #{name}" if  !detect || !test

        puts "Finished installing #{name}"
      end
    end

    def remove
      puts "Removing #{name}"
      instance_eval &remove_proc

      raise "Failed removing #{name}" if detect || test

      puts "Finished removing #{name}"
    end

    def test
      instance_eval &test_proc
    end

    def detect
      !detect_files.map do |file|
        file_exists? file
      end.include?(false)
    end

    def enable
      raise "Not implemented"
    end

    def disable
      raise "Not implemented"
    end

    private

    def apt_install(packages)
      exec "aptitude install -y #{packages}"
    end

    def wget(url)
      exec "wget \"#{url}\""
    end

    def untar(file)
      exec "tar xvzf #{file}"
    end

    def cd(dir = nil)
      @directory = dir
    end

    def rm(file)
      exec "rm -rf \"#{file}\""
    end

    def exec(script)
      [*script].map do |line|
        line = "cd #{@directory} ; #{line}" if @directory
        server.ssh(line).last
      end.last
    end

    def file_exists?(file)
      exec("find #{file}").status == 0
    end

    def assert_stdout(script, check)
      !!exec(script).stdout.match(check)
    end

    def update_metadata
      result = server.ssh %{echo "#{MultiJson.encode(server.metadata)}" > ~/metadata.json}
      raise "Failed updating metadata for #{name}" unless result.last.status == 0
    end

    class << self
      def load(name)
        Component::DSL.load(name)
      end
    end
  end
end


