class Scotty::Component::DSL
  attr_accessor :base

  def initialize
    @base = Scotty::Component.new
  end

  def name(name)
    base.name = name
  end

  def config(&block)
    base.config_proc = block
  end

  def test(&block)
    base.test_proc = block
  end

  def configure(&block)
    base.configure_proc = block
  end

  def install(&block)
    base.install_proc = block
  end

  def remove(&block)
    base.remove_proc = block
  end

    def self.load(server, role, name)
    component = new
    component.base.server = server
    component.base.role = role
    component.base.path = "#{File.dirname(__FILE__)}/../../data/roles/#{role}/#{name}"
    component.instance_eval(File.open("#{component.base.path}/scotty.rb").read)
    component.base
  end

end

