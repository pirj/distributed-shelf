require 'rest_client'
require 'dshelf/dfile'
require 'dshelf/stat'

class File
  class << self; include DistributedShelf end
  def absolutepath; File.expand_path path, Dir.pwd end

  [:'pipe?', :'socket?', :'sticky?'].each do |method|
    proxy_method(method) do |filename| false end
  end

  [:atime, :ctime, :mtime, :'directory?', :'file?', :'owned?', :size, :'symlink?', :'zero?',
    :'readable?', :'writable?', :'readable_real?', :'writable_real?'].each do |method|
    proxy_method(method) do |filename|
      File.stat(filename).send(method)
    end
  end

  [:'exist?', :'exists?', :delete, :unlink, :rename, :link, :symlink].each do |method|
    safe_method = method.to_s.gsub '?', '_QM'
    proxy_method(method) do |*args|
      RestClient.get("#{server_url}/meta", {:params => {:method => safe_method, :pwd => Dir.pwd, :args => args}})
    end
  end

  proxy_method(:truncate) do |filename, size|
    absolutepath = File.expand_path filename, Dir.pwd
    RestClient.get("#{server_url}/truncate#{absolutepath}", {:params => {:size => size}}) do |response, request, result|
      case response.code
      when 200
        0
      when 404
        raise Errno::ENOENT
      end        
    end
  end

  [:stat, :lstat].each do |method|
    proxy_method(method) do |filename|
      Stat.new(filename)
    end
  end

  proxy_method(:new) do |*args|
    DistributedFile.new(*args)
  end

  proxy_method(:open) do |*args, &b|
    DistributedFile.open(*args, &b)
  end
end
