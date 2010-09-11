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

  proxy_method(:open) do |*args, &b|
    DistributedFile.open(*args, &b)
  end

  [:truncate].each do |method|
    proxy_method(method) do |file, integer|
      "distributed truncate #{method} on #{file} to #{integer} bytes"
    end
  end
end

# "r"  |  Read-only, starts at beginning of file  (default mode).
# -----+--------------------------------------------------------
# "r+" |  Read-write, starts at beginning of file.
# -----+--------------------------------------------------------
# "w"  |  Write-only, truncates existing file
#      |  to zero length or creates a new file for writing.
# -----+--------------------------------------------------------
# "w+" |  Read-write, truncates existing file to zero length
#      |  or creates a new file for reading and writing.
# -----+--------------------------------------------------------
# "a"  |  Write-only, starts at end of file if file exists,
#      |  otherwise creates a new file for writing.
# -----+--------------------------------------------------------
# "a+" |  Read-write, starts at end of file if file exists,
#      |  otherwise creates a new file for reading and
#      |  writing.
# -----+--------------------------------------------------------
#  "b" |  Binary file mode (may appear with
#      |  any of the key letters listed above).
#      |  Suppresses EOL <-> CRLF conversion on Windows. And
#      |  sets external encoding to ASCII-8BIT unless explicitly
#      |  specified.
# -----+--------------------------------------------------------
#  "t" |  Text file mode (may appear with
#      |  any of the key letters listed above except "b").
       
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
  
  def close
    p "closing #{path}"
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
  
# File.open(filename, mode="r" [, opt]) => file
# File.open(filename [, mode [, perm]] [, opt]) => file
# File.open(filename, mode="r" [, opt]) {|file| block } => obj
# File.open(filename [, mode [, perm]] [, opt]) {|file| block } => obj
    
  def self.open filename, *args, &b
    p "opening #{filename}"
    f = self.new filename, *args
    if b
      p "block given"
      b.call(f)
      f.close
    else
      p "bo block given"
      f
    end
  end
  
  def method_missing method
    raise "Distributed shelf error: #{method} not implemented"
  end
end
