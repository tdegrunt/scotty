class Scotty::Component::DSL
  attr_accessor :base

  def initialize
    @base = Scotty::Component.new
  end

  def name(name)
    base.name = name
  end

  def requires_apt(packages)
    base.requires_apt = packages
  end

  def provides(packages)
    base.provides = packages
  end

  def test(&block)
    base.test_proc = block
  end

  def detect(files)
    base.detect_files = [*files]
  end

  def install(script)
    base.install_script = script.split("\n").compact
  end

  def remove(script)
    base.remove_script = script.split("\n").compact
  end

  def self.load(name)
    component = new
    component.instance_eval(File.open("#{File.dirname(__FILE__)}/components/#{name}").read)
    component.base
  end

end

