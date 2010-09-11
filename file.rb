require 'distributed.rb'

class File
  [:atime, :ctime, :mtime, :'directory?'].each do |method|
    proxy_method(method) do ||
      "distributed #{method}"
    end
  end


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
# File.open(filename, mode="r" [, opt]) => file
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

  # read
  # write
end
