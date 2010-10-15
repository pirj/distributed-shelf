module DistributedShelf
  VERSION = '0.2'

  @@config = {}
  
  def override_class_method method, &b
    (class << self; self; end).class_eval do
      alias_method "_#{method.to_s}".to_sym, method
      define_method method, &b
    end
  end

  def distributed? file
    @@config[:distributed_path] and not File.expand_path(file).match(@@config[:distributed_path]).nil?
  end

  def proxy_method(method, &b)
    old_method = :"_#{method}"
    override_class_method(method) do |*args, &bl|
      if distributed? args[0]
        b.call(*args, &bl)
      else
        self.send(old_method, *args, &bl)
      end
    end
  end

  def self.config= conf
    @@config = conf
    @@config[:distributed_path] == Regexp.new('^' + @@config[:distributed_path] + '/')
  end

  def server_url
    @@config[:storage_url]
  end

  def absolutepath
    File.expand_path path, Dir.pwd
  end
end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'dshelf/dir'
require 'dshelf/dfile'
require 'dshelf/file'
require 'dshelf/stat'

