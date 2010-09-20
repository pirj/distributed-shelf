require 'dshelf'
require 'json'

class DistributedStat
  include DistributedShelf
  def path
    @path
  end

  def initialize filename
    @path = filename
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
    @stat = JSON.parse stat
    p "stat=#{@stat}"
  end

    # atime   blksize   blockdev?   blocks   chardev?   ctime   dev   
    # dev_major   dev_minor   directory?   executable?   executable_real?
    # file?   ftype   gid   grpowned?   ino   inspect   mode   mtime   new
    # nlink   owned?   pipe?   pretty_print   rdev   rdev_major   rdev_minor
    # readable?   readable_real?   setgid?   setuid?   size   size?   socket?
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
