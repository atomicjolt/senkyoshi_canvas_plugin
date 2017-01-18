$:.push File.expand_path("../lib", __FILE__)

require "senkyoshi_canvas_plugin/version"

Gem::Specification.new do |spec|
  spec.name          = "senkyoshi_canvas_plugin"
  spec.version       = SenkyoshiCanvasPlugin::VERSION
  spec.authors       = ["James Carbine"]
  spec.email         = ["james.carbine@atomicjolt.com"]
  spec.homepage      = "http://www.atomicjolt.com"
  spec.summary       = "Senkyoshi Blackboard importer"
  spec.license       = "AGPL-3.0"
  spec.extra_rdoc_files = ["README.md"]

  spec.required_ruby_version = ">= 2.0"

  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.test_files = Dir["spec_canvas/**/*"]

  spec.add_dependency "rails", ">= 3.2", "< 5.1"
  spec.add_dependency "canvas_cc"
  spec.add_dependency "senkyoshi"
end
