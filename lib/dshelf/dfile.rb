require 'rest_client'

class DistributedFile
  include DistributedShelf

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
  def initialize filename, mode='r', *args, &block
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
      parse RestClient.get("#{server_url}/#{method}", {:params => {:pwd => Dir.pwd, :filename => path}, :accept => :json})
    end
  end
  
  def close
    # p "#{path}: closing"
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
    params = {}
    params[:length] = length unless length == 0
    params[:offset] = offset unless offset == 0
    RestClient.get("#{server_url}#{absolutepath}",
      {:params => params}) do |response, request, result|
      case response.code
      when 200
        response
      when 404
        raise Errno::ENOENT
      end        
    end
  end

  def absolutepath
    File.expand_path path, Dir.pwd
  end

  def write string
    resource = RestClient::Resource.new "#{server_url}#{absolutepath}"
    resource.put string, :content_type => mimetype
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
    raise "Distributed File error: #{method} not implemented"
  end
end
