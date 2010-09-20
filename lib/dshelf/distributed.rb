require 'time'
require 'json'

module DistributedShelf
  def override_class_method method, &b
    (class << self; self; end).class_eval do
      alias_method "_#{method.to_s}".to_sym, method
      define_method method, &b
    end
  end

  def distributed? file
    not File.absolute_path(file).match(@@config[:distributed_path]).nil?
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

  def parse response_data
    p "response_data"
    p response_data
    response = JSON.parse response_data
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

  def absolutepath
    File.expand_path path, Dir.pwd
  end

  def class_for_name name
    namespaces = name.split '::'
    base = Kernel
    namespaces.each do |namespace| base = base.const_get(namespace) end
    base
  end

  def self.config= conf
    @@config = conf
    @@config[:distributed_path] == Regexp.new('^' + @@config[:distributed_path] + '/')
  end

  def server_url
    @@config[:storage_url]
  end
end
