require 'distributed.rb'

class File
  override_instance_method(:atime) {
    p "in i atime"
    "proxied atime #{_atime}"
  }
    
  override_class_method(:atime) { |file|
    p "in c atime"
    "proxied 2 atime #{_atime(file)}"
  }

  # def override_instance_method method, &blk # http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  #   (class << self; self; end).instance_eval {
  #   alias_method "_#{method.to_s}".to_sym, method
  #     define_method method, &blk
  #   }
  #   p "overriding instance method #{method}"
  # end
  # 
  # def self.override_class_method method, &blk
  #   (class << self; self; end).class_eval {
  #     alias_method "_#{method.to_s}".to_sym, method
  #     define_method method, &blk
  #   }
  #   p "overriding class method #{method}"
  # end

  # override_instance_method(:atime) {
  #   "proxied inst atime #{self._atime}"
  # }
end

    #ctime
    #
    # delete(file, ...)
    # unlink
    # 
    # directory?
    # 
    # exist?
    # exists?
    # 
    # file?
    # 
    # link old_name, new_name
    # 
    # lstat
    # 
    # mtime
    # 
    # init filename, mode
    # 
    # open()
#     File.open(filename, mode="r" [, opt]) => file
# File.open(filename [, mode [, perm]] [, opt]) => file
# File.open(filename, mode="r" [, opt]) {|file| block } => obj
# File.open(filename [, mode [, perm]] [, opt]) {|file| block } => obj
    
    # owned?
    # 
    # readable?
    # 
    # rename(old_name, new_name) => 0
    # 
    # size
    # 
    # socket?
    # 
    # sticky?
    # 
    # symlink
    # 
    # symlink?
    # 
    # truncate(file, integer)
    # 
    # writable?
    # 
    # zero?
  # end
  
  # atime
  # 
  # ctime
  # 
  # lstat
  # 
  # mtime
  # 
  # truncate
# end
