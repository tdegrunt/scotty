# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scotty/version"

Gem::Specification.new do |s|
  s.name        = "scotty"
  s.version     = Scotty::VERSION
  s.authors     = ["Andre Meij", "Mark Kremer"]
  s.email       = ["andre@socialreferral.com", "mark@socialreferral.com"]
  s.summary     = %q{Scotty, using Teleport and Fog to automate infrastructure}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "fog"
  s.add_runtime_dependency "teleport"
end
