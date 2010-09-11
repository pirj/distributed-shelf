require 'distributed.rb'

class File
  [:atime, :ctime, :mtime, :'directory?', :'exist?', :'exists?', :'file?', :'owned?', :'pipe?',
    :'readable?', :size, :'socket?', :'sticky?', :'symlink?', :'writable?', :'zero?'
    ].each do |method|
    proxy_method(method) do |file|
      "distributed #{method} on #{file}"
    end
  end

  [:delete, :unlink].each do |method|
    proxy_method(method) do |*files|
      files.each do |file|
        p "distributed remove #{method} on #{file}"
      end
      files.size
    end
  end
  
  [:rename].each do |method|
    proxy_method(method) do |old_name, new_name|
      "distributed rename #{method} on #{old_name} => #{new_name}"
    end
  end
  
  [:link, :symlink].each do |method|
    proxy_method(method) do |old_name, new_name|
      "distributed link #{method} on #{old_name}, #{new_name}"
    end
  end
  
  [:lstat, :stat].each do |method|
    proxy_method(method) do |file|
      "distributed stat info #{method} on #{args[0]}"
    end
  end
  
  proxy_method(:new) do |*args|
    DistributedFile.new(*args)
  end

  # init filename, mode
  # 
# File.open(filename, mode="r" [, opt]) => file
# File.open(filename [, mode [, perm]] [, opt]) => file
# File.open(filename, mode="r" [, opt]) {|file| block } => obj
# File.open(filename [, mode [, perm]] [, opt]) {|file| block } => obj
    
  [:truncate].each do |method|
    proxy_method(method) do |file, integer|
      "distributed truncate #{method} on #{file} to #{integer} bytes"
    end
  end
end

class DistributedFile
  def initialize filename, mode='r', *args
    @filename = filename
    @mode = mode
  end

  def path
    @filename
  end

  [:atime, :ctime, :mtime].each do |method|
    define_method method do
      "distributed time #{method}"
    end
  end

  [:lstat, :stat].each do |method|
    define_method method do
      "distributed stat info #{method}"
    end
  end

  [:truncate].each do |method|
    define_method method do |integer|
      "distributed truncate #{method} on #{@filename} to #{integer} bytes"
    end
  end

  def read length=0, *args
    "remote read"
  end
  
  def write string
    "remote write #{string.length} bytes"
  end
  
  def method_missing method
    raise "Distributed shelf error: #{method} not implemented"
  end
end
