$:.push File.expand_path("../lib", __FILE__)

require "gandi/version"

Gem::Specification.new do |s|
  s.name        = "viaduct-gandi"
  s.version     = Gandi::VERSION
  s.authors     = ["Adam Cooke"]
  s.email       = ["adam@viaduct.io"]
  s.homepage    = "http://viaduct.io"
  s.summary     = "A Gandi module."
  s.description = "A Gandi module for working with domain registrations."
  s.files = Dir["{lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
end
