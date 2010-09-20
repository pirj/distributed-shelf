require 'dshelf'
require 'json'
require 'time'

class DistributedStat
  include DistributedShelf
  def path
    @dpath
  end

  def initialize filename
    @dpath = filename
    RestClient.get("#{server_url}/stat#{absolutepath}", {:accept => :json}) do |response, request, result|
      case response.code
      when 200
        parse_stat response
      when 404
        raise Errno::ENOENT
      end
    end
  end
  
  def parse_stat stat
    parsed = JSON.parse stat
    @dstat = {}
    @dstat[:size] = parsed['size']
    @dstat[:atime] = Time.parse parsed['atime']
    @dstat[:ctime] = Time.parse parsed['ctime']
    @dstat[:mtime] = Time.parse parsed['mtime']
  end

  def setgid?; true end
  def setuid?; true end

  def size
    @dstat[:size]
  end
  
  def atime
    @dstat[:atime]
  end

  def ctime
    @dstat[:ctime]
  end

  def mtime
    @dstat[:mtime]
  end

    # atime   blksize   blockdev?   blocks   chardev?   ctime   dev   
    # dev_major   dev_minor   directory?   executable?   executable_real?
    # file?   ftype   gid   grpowned?   ino   inspect   mode   mtime   new
    # nlink   owned?   pipe?   pretty_print   rdev   rdev_major   rdev_minor
    # readable?   readable_real?      size   size?   socket?
    # sticky?   symlink?   uid   writable?   writable_real?   zero? 

  # def method_missing method
  #   raise "Distributed File::Stat error: #{method} not implemented"
  # end
end

class File
  class Stat
    class << self; include DistributedShelf end

    proxy_method(:new) do |filename|
      DistributedStat.new filename
    end
  end
end
