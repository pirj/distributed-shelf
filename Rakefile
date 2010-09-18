desc 'Specs'
task :specs do
  p "spec"
end

task :default => :specs

begin
  $: << File.join(File.dirname(__FILE__), 'lib')
  require 'jeweler'
  require 'dshelf'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "dshelf"
    gemspec.summary = ""
    gemspec.description = ""
    gemspec.email = "pirj@mail.ru"
    gemspec.homepage = "http://distributedshelf.com"
    gemspec.authors = ["Phil Pirozhkov"]

    # gemspec.add_development_dependency(%q<turn>, [">= 0"])
    gemspec.add_dependency(%q<rest-client>, ["~> 1.4.0"])
    gemspec.add_dependency(%q<json>, ["~> 1.2.0"])
    gemspec.add_dependency(%q<multipart-post>, ["~> 1.0.0"])
    gemspec.add_dependency(%q<mime-types>, ["~> 1.0"])

    gemspec.version = DistributedShelf::VERSION
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
