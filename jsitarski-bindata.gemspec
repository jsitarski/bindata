# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bindata/version'

Gem::Specification.new do |gem|
  gem.name          = "jsitarski-bindata"
  gem.version       = BinData::VERSION
  gem.authors       = ["John-Paul Sitarski"]
  gem.email         = ["jsitarski@gmail.com"]
  gem.description   = %q{BinData is a declarative way to read and write binary file formats.


  This means the programmer specifies *what* the format of the binary

  data is, and BinData works out *how* to read and write data in this

  format.  It is an easier ( and more readable ) alternative to

  ruby''s #pack and #unpack methods.}
  gem.summary       = %q{A declarative way to read and write binary file formats}
  gem.homepage      = "http://bindata.rubyforge.org"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

	gem.add_development_dependency 'rspec', '2.13.0'
	gem.add_development_dependency 'rake', '>=0.9.2.2'

end
