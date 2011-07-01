# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vitunes/version"

Gem::Specification.new do |s|
  s.name        = "vitunes"
  s.version     = ViTunes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.6'

  s.authors     = ["Daniel Choi"]
  s.email       = ["dhchoi@gmail.com"]
  s.homepage    = "http://danielchoi.com/software/vitunes.html"
  s.summary     = %q{A Vim interface to iTunes}
  s.description = %q{Control iTunes with Vim}

  s.rubyforge_project = "vitunes"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

