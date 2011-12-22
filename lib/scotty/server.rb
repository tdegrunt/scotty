module Scotty
  class Server
    def initialize(fog_server)
      @fog_server = fog_server
    end

    def name
      fog.name
    end

    def public_ip
      fog.addresses["public"].first
    end

    def private_ip
      fog.addresses["private"].first
    end

    def role
      @role ||= fog.ssh("cat .role").last.stdout.strip.to_sym
    end

    def ssh(*args)
      fog.ssh *args
    end

    def scp(*args)
      fog.scp *args
    end

    def fog
      @fog_server
    end
  end
end
