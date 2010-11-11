require 'rest_client'
# require 'httpclient'
require 'mime/types'

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
      "application/octet-stream"
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
      DistributedStat.new path
    end
  end

  [:truncate].each do |method|
    define_method method do |integer|
      "#{path}: distributed truncate #{method} to #{integer} bytes"
    end
  end

  def read length=0, offset=0
  #   if RUBY_VERSION >= '1.8.7' then
  #     # stream
  #     Stream.new "#{server_url}/storage#{URI.escape absolutepath}"
  #   else
  #     read_full length, offset
  #   end
  # end
  # 
  # def read_full length=0, offset=0
    params = {}
    params[:length] = length unless length == 0
    params[:offset] = offset unless offset == 0
    RestClient.get("#{server_url}/storage#{URI.escape absolutepath}",
      {:params => params}) do |response, request, result|
      case response.code
      when 200
        response
      when 402
        raise Errno::ENOSPC
      when 404
        raise Errno::ENOENT, absolutepath
      end
    end
  end

  def puts *args
    write args.join("\n")
  end

  def write string
    RestClient.put "#{server_url}/storage#{URI.escape absolutepath}", string, :content_type => mimetype do |response, request, result|
      case response.code
      when 204
        string.size
      when 402
        raise Errno::ENOSPC
      end
    end
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

# class Stream
#   def initialize path
#     @path = path
#   end
# 
#   def each
#     HTTPClient.get_content(@path) do |chunk|
#       p "chunk rcv: #{chunk.size}"
#       yield chunk
#       p "chunk rcv rt: #{chunk.size}"
#     end
#   end
# end
