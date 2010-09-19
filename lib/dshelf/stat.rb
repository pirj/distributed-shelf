class File
  class Stat
    class << self
      include DistributedShelf
    end

    proxy_method(:new) do |*args|
      DistributedStat.new(*args)
    end
    # atime   blksize   blockdev?   blocks   chardev?   ctime   dev   dev_major   dev_minor   directory?   executable?   executable_real?   file?   ftype   gid   grpowned?   ino   inspect   mode   mtime   new   nlink   owned?   pipe?   pretty_print   rdev   rdev_major   rdev_minor   readable?   readable_real?   setgid?   setuid?   size   size?   socket?   sticky?   symlink?   uid   writable?   writable_real?   zero? 
  end
end

class File
  class DistributedStat
    def initialize filename
      @filename = filename
    end

    def method_missing method
      raise "Distributed File::Stat error: #{method} not implemented"
    end
  end
end
