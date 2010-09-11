module DistributedShelf
  def security_token
    'fsdgsdfgsdfv32qwg'
  end
  
  def server_url
    'http://localhost:9292/storage'
  end
  
  def override_class_method method, &b
    (class << self; self; end).class_eval do
      alias_method "_#{method.to_s}".to_sym, method
      define_method method, &b
    end
  end
  
  def distributed? file
    not File.absolute_path(file).match(/\/remote/).nil?
  end
  
  def proxy_method(method, &b)
    old_method = :"_#{method}"
    override_class_method(method) do |*args, &bl|
      if distributed? args[0]
        b.call(*args, &bl)
      else
        self.send(old_method, *args, &bl)
      end
    end
  end
end

class File
  class << self
    include DistributedShelf
  end
end

class Dir
  class << self
    include DistributedShelf
  end
end
