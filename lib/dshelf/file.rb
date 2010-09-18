require 'rest_client'
require 'json'
require 'net/http/post/multipart'
require 'mime/types'

class File
  [:atime, :ctime, :mtime, :'directory?', :'exist?', :'exists?', :'file?', :'owned?', :'pipe?',
    :'readable?', :size, :'socket?', :'sticky?', :'symlink?', :'writable?', :'zero?'
    ].each do |method|
    method_short = method.to_s.gsub '?', '_QM'
    proxy_method(method) do |filename|
      remote "#{server_url}/class/#{method_short}", {:params => {:pwd => Dir.pwd, :filename => filename, :token => security_token}, :accept => :json}
    end
  end

  [:delete, :unlink].each do |method|
    proxy_method(method) do |*files|
      remote "#{server_url}/class/#{method}", {:params => {:pwd => Dir.pwd, :files => files, :token => security_token}, :accept => :json}
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
  
  def mimetype
    return @mimetype if @mimetype
    @mimetype = MIME::Types.type_for(File.basename path)
    @mimetype = if @mimetype.empty?
      ""
    else
      @mimetype[0]
    end
  end

  [:atime, :ctime, :mtime].each do |method|
    define_method method do
      remote "#{server_url}/#{method}", {:params => {:pwd => Dir.pwd, :filename => path, :token => security_token}, :accept => :json}
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

  def read length=0, offset=0
    remote "#{server_url}/read", {:params => {:length => length, :offset => offset, :pwd => Dir.pwd, :filename => path, :token => security_token}, :accept => :json}
  end
  
  def write string
    data = StringIO.new string
    
    url = URI.parse("#{server_url}/write")
    req = Net::HTTP::Post::Multipart.new url.path,
      :file => UploadIO.new(data, mimetype, path),
      :filename => path

    res, body = Net::HTTP.start(url.host, url.port) do |http| http.request(req) end
    res
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
