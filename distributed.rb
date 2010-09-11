module DistributedShelf
  def override_class_method method, &b
    (class << self; self; end).class_eval do
      alias_method "_#{method.to_s}".to_sym, method
      define_method method, &b
    end
  end

  def override_instance_method method, &b
    alias_method "_#{method.to_s}".to_sym, method
    self.send :define_method, method, &b
  end
  
  def distributed? file
    not file.match(/\/remote/).nil?
  end
  
  def proxy_method(method, &b)
    old_method = :"_#{method}"
    override_class_method(method) do |file|
      if distributed? file
        b.call file
      else
        "calling original #{method} is #{self.send(old_method, file)}"
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
