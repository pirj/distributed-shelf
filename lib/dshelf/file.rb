require 'rest_client'
require 'dshelf/dfile'
require 'dshelf/stat'

class File
  class << self
    include DistributedShelf
  end

  [:'pipe?', :'socket?', :'sticky?'].each do |method|
    proxy_method(method) do |filename| false end
  end

  [:'readable?', :'writable?'].each do |method|
    proxy_method(method) do |filename| true end
  end

  [:atime, :ctime, :mtime, :'directory?', :'file?', :'owned?', :size, :'symlink?', :'zero?'].each do |method|
    proxy_method(method) do |filename|
      File.stat(filename).send(method)
    end
  end

  [:'exist?', :'exists?', :delete, :unlink, :rename, :link, :symlink, :truncate].each do |method|
    safe_method = method.to_s.gsub '?', '_QM'
    proxy_method(method) do |*args|
      parse RestClient.get("#{server_url}/meta/#{safe_method}", {:params => {:pwd => Dir.pwd, :args => args}})
    end  #:accept => :json
  end

  [:stat, :lstat].each do |method|
    proxy_method(method) do |filename|
      DistributedStat.new(filename)
    end
  end

  proxy_method(:new) do |*args|
    DistributedFile.new(*args)
  end

  proxy_method(:open) do |*args, &b|
    DistributedFile.open(*args, &b)
  end
end
