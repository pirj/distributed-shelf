$:.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'dshelf'

Gem::Specification.new do |gem|
  gem.name     = "dshelf"
  gem.version  = ::DistributedShelf::VERSION
  gem.description = "Transparent remote storage for File API"
  gem.summary  = "Transparent remote storage for File API"
  gem.authors = ["Phil Pirozhkov"]
  gem.date = Time.now.strftime '%Y-%m-%d'
  gem.email = "pirj@mail.ru"
  gem.homepage = "https://distributedshelf.com"
  gem.rdoc_options = ["--charset=UTF-8"]
  gem.require_paths = ["lib"]
  gem.files = [
    'lib/dshelf.rb',
    'lib/dshelf/dfile.rb',
    'lib/dshelf/dir.rb',
    'lib/dshelf/file.rb',
    'lib/dshelf/stat.rb'
    ]

  gem.add_dependency "rest-client", ["~> 1.6.1"]
  gem.add_dependency "json", ["~> 1.2.0"]
  gem.add_dependency "mime-types", ["~> 1.0"]
end
