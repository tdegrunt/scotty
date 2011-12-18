class Scotty::Component::DSL
  attr_accessor :base

  def initialize
    @base = Scotty::Component.new
  end

  def name(name)
    base.name = name
  end

  def requires(packages)
    base.requires = packages
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

  def install(&block)
    base.install_proc = block
  end

  def remove(&block)
    base.remove_proc = block
  end

  def self.load(name)
    component = new
    component.instance_eval(File.open("#{File.dirname(__FILE__)}/components/#{name}").read)
    component.base
  end

end

