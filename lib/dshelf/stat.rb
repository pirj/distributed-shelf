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
    # p "dstat of #{@dpath} is #{parsed}"
    @dstat = {}
    @dstat[:size] = parsed['size']
    @dstat[:atime] = Time.parse parsed['atime']
    @dstat[:ctime] = Time.parse parsed['ctime']
    @dstat[:mtime] = Time.parse parsed['mtime']
    @dstat[:is_file] = parsed['is_file']
    @dstat[:is_dir] = parsed['is_dir']
    @dstat[:is_regular] = parsed['is_regular']
  end

  def setgid?; true end
  def setuid?; true end

  def size
    @dstat[:size]
  end
  
  def zero?
    size == 0
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

  def <=> stat
    mtime <=> stat.mtime
  end

  [:'pipe?', :'socket?', :'sticky?', :'blockdev?', :'chardev?', :'executable?', :'executable_real?'].each do |method|
    define_method(method) do || false end
  end

  [:blksize, :blocks].each do |method|
    define_method(method) do || nil end
  end
  
  def file?
    @dstat[:is_regular]
  end
  
  def directory?
    @dstat[:is_dir]
  end
  
  def symlink?
    not @dstat[:is_file]
  end
  
  def ftype
    return 'link' if symlink?
    return 'directory' if directory?
    'file'
  end

    # dev   dev_major   dev_minor   
    #       gid   grpowned?   ino   inspect   mode
    # nlink   owned?   pretty_print   rdev   rdev_major   rdev_minor
    # readable?   readable_real?
    #    uid   writable?   writable_real? 
end

class File
  class Stat
    class << self; include DistributedShelf end

    proxy_method(:new) do |filename|
      DistributedStat.new filename
    end
  end
end
