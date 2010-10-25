$:.unshift File.expand_path("../lib", __FILE__)

require "parka/specification"

Parka::Specification.new do |gem|
  gem.name     = "dshelf"
  gem.version  = DistributedShelf::VERSION
  gem.summary  = "A sample gem"
  gem.homepage = "http://example.org"
  gem.authors = ["Phil Pirozhkov"]
  gem.date = Time.now.strftime '%Y-%m-%d'
  gem.description = "Transparent remote storage for File API"
  gem.email = "pirj@mail.ru"
  gem.homepage = "https://distributedshelf.com"
  # gem.rdoc_options = ["--charset=UTF-8"]
  gem.require_paths = ["lib"]
  # s.files = [
  #   'lib/dshelf.rb',
  #   'lib/dshelf/dfile.rb',
  #   'lib/dshelf/dir.rb',
  #   'lib/dshelf/file.rb',
  #   'lib/dshelf/stat.rb'
  #   ]
end

