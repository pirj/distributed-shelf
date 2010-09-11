require 'distributed.rb'

class File
  def self.proxy_method(method)
    old_method = :"_#{method}"
    override_class_method(method) do |file|
      "#{method} is #{self.send(old_method, file)}"
    end
  end

  [:atime, :ctime, :mtime].each do |method|
    proxy_method(method)
  end

  # override_class_method(:atime) do |file|
  #   "proxied c atime #{_atime(file)}"
  # end
  # 
  # override_class_method(:ctime) do |file|
  #   "proxied c atime #{_ctime(file)}"
  # end
  # 
  # override_class_method(:mtime) do |file|
  #   "proxied c atime #{_mtime(file)}"
  # end

    #ctime
    # mtime


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
  
  # override_instance_method(:atime) {
  #   p "in i atime"
  #   "proxied atime #{_atime}"
  # }
    
  # atime
  # 
  # ctime
  # 
  # lstat
  # 
  # mtime
  # 
  # truncate
end
