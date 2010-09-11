require 'distributed.rb'
require 'rest_client'
require 'json'

class File
  [:atime, :ctime, :mtime, :'directory?', :'exist?', :'exists?', :'file?', :'owned?', :'pipe?',
    :'readable?', :size, :'socket?', :'sticky?', :'symlink?', :'writable?', :'zero?'
    ].each do |method|
    proxy_method(method) do |file|
      remote "#{server_url}/class/#{method}", {:params => {:pwd => Dir.pwd, :file => file, :token => security_token}, :accept => :json}
    end
  end

  [:delete, :unlink].each do |method|
    proxy_method(method) do |*files|
      files.each do |file|
        p "#{file}: distributed remove #{method}"
      end
      files.size
    end
  end
  
  [:rename, :link, :symlink, :truncate].each do |method|
    proxy_method(method) do |*args|
      remote "#{server_url}/#{method}", {:params => {:pwd => Dir.pwd, :args => args, :token => security_token}, :accept => :json}
    end
  end
  
  [:lstat, :stat].each do |method|
    proxy_method(method) do |file|
      "#{file}: distributed stat info #{method} on #{file}"
    end
  end
  
  proxy_method(:new) do |*args|
    DistributedFile.new(*args)
  end

  proxy_method(:open) do |*args, &b|
    DistributedFile.open(*args, &b)
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
  include DistributedShelf

  def initialize filename, mode='r', *args
    @filename = filename
    @mode = mode
  end

  def path
    @filename
  end

  [:atime, :ctime, :mtime].each do |method|
    define_method method do
      remote "#{server_url}/#{method}", {:params => {:pwd => Dir.pwd, :file => path, :token => security_token}, :accept => :json}
    end
  end
  
  def close
    p "#{path}: closing"
  end

  [:lstat, :stat].each do |method|
    define_method method do
      "#{path}: distributed stat info #{method}"
    end
  end

  [:truncate].each do |method|
    define_method method do |integer|
      "#{path}: distributed truncate #{method} to #{integer} bytes"
    end
  end

  def read length=0, *args
    "#{path}: remote read"
  end
  
  def write string
    "#{path}: remote write #{string.length} bytes"
  end
  
# File.open(filename, mode="r" [, opt]) => file
# File.open(filename [, mode [, perm]] [, opt]) => file
# File.open(filename, mode="r" [, opt]) {|file| block } => obj
# File.open(filename [, mode [, perm]] [, opt]) {|file| block } => obj
    
  def self.open filename, *args, &b
    f = self.new filename, *args
    if b
      b.call(f)
      f.close
    else
      f
    end
  end
  
  def method_missing method
    raise "Distributed shelf error: #{method} not implemented"
  end
end
