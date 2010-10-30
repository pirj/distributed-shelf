require 'json'

class Dir
  class << self; include DistributedShelf end

  override_class_method(:chdir) do |dir|
    if distributed? dir
      p "remote chdir"
      @@dpwd = dir
    else
      @@dpwd = ''
      Dir._chdir dir
    end
  end

  @@dpwd = ''
  [:getwd, :pwd].each do |method|
    override_class_method(method) do
      if distributed? @@dpwd
        p "remote pwd"
        @@dpwd
      else
        Dir._pwd
      end
    end
  end
  
  [:delete, :rmdir, :unlink].each do |method|
    proxy_method(method) do |dir|
      RestClient.delete("#{server_url}/dir#{dir}") do |response, request, result|
        case response.code
        when 202
          0
        when 204
          0
        when 404
          raise Errno::ENOENT
        end
      end
    end
  end

  proxy_method(:entries) do |dir|
    dir = File.expand_path(dir, Dir.pwd)
    RestClient.get("#{server_url}/dir#{dir}", {:accept => :json}) do |response, request, result|
      case response.code
      when 200
        JSON.parse response
      when 404
        raise Errno::ENOENT
      end
    end
  end

  proxy_method(:mkdir) do |dir|
    RestClient.put("#{server_url}/dir#{dir}", '') do |response, request, result|
      case response.code
      when 204
        0
      when 409
        raise Errno::EEXIST
      end
    end
  end

    # foreach(dirname, &b)
    # 
    # init (name)
    # 
    # open(name)
    # 
    # open(name, &b)
    # 



  
  # ?close
  # 
  # each &b
  # 
  # path
  # 
  # ?seek
  # ?pos
  # ?tell
  # 
  # read
  # 
end