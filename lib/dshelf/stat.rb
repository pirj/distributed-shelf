require 'dshelf'

class File
  class Stat
    class << self
      include DistributedShelf
    end

    proxy_method(:new) do |*args|
      DistributedStat.new(*args)
    end
    # atime   blksize   blockdev?   blocks   chardev?   ctime   dev   
    # dev_major   dev_minor   directory?   executable?   executable_real?
    # file?   ftype   gid   grpowned?   ino   inspect   mode   mtime   new
    # nlink   owned?   pipe?   pretty_print   rdev   rdev_major   rdev_minor
    # readable?   readable_real?   setgid?   setuid?   size   size?   socket?
    # sticky?   symlink?   uid   writable?   writable_real?   zero? 
  end
end

class File
  class DistributedStat
    include DistributedShelf
    class << self
      include DistributedShelf
    end

    def initialize filename
      # todo: FIX!!! need to come from DShelf
      absolutepath = File.expand_path filename, Dir.pwd

      RestClient.get("#{server_url}/stat#{absolutepath}", {:accept => :json}) do |response, request, result|
        case response.code
        when 200
          response
        when 404
          raise Errno::ENOENT
        end
      end
    end

    # def method_missing method
    #   raise "Distributed File::Stat error: #{method} not implemented"
    # end
  end
end
