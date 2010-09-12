require 'time'

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
  
  def remote url, params
    response = JSON.parse RestClient.get url, params
    if response['error']
      raise class_for_name(response['class']).new(response['error'])
    else
      case response['class']
      when 'String'
        response['result']
      when 'Integer'
        response['result'].to_i
      when 'Fixnum'
        response['result']
      when 'Time'
        Time.parse response['result']
      when 'FalseClass'
        false
      when 'TrueClass'
        true
      else
        raise "need conversion #{response}"
      end
    end
  end
  
  def class_for_name name
    namespaces = name.split '::'
    base = Kernel
    namespaces.each do |namespace| base = base.const_get(namespace) end
    base
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
