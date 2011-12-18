module Scotty
  class Component
    attr_accessor :name, :server, :requires_apt, :provides, :install_script, :remove_script, :detect_files, :test_proc

    def install_dependencies
      puts "Installing dependencies"
      result = exec("aptitude install -y #{requires_apt.join(" ")}")

      if result.status != 0
        puts result.stdout
        raise "Failed installing dependencies (#{requires_apt})"
      end
      result
    end

    def install
      install_dependencies

      puts "Installing #{name}"
      result = exec(install_script)
      puts "Testing #{name}"
      if result.status != 0 || !detect || !test
        # logger.debug
        raise "Failed installing #{name}"
      end
      puts "Finished installing #{name}"
      result
    end

    def test
      instance_eval &test_proc
    end

    def detect
      !detect_files.map do |file|
        file_exists? file
      end.find(false)
    end

    private

    def exec(script)
      result = server.ssh(script).first
    end

    def file_exists?(file)
      exec("find #{file}").status == 0
    end

    def assert_stdout(script, check)
      !!exec(script).stdout.match(check)
    end

    class << self
      def load(name)
        Component::DSL.load(name)
      end
    end
  end
end


