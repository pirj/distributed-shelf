module DistributedShelf
  def override_class_method method, &b
    (class << self; self; end).class_eval do
      p "overriding class method #{method} in #{self}"
      alias_method "_#{method.to_s}".to_sym, method
      define_method method, &b
    end
  end

  def override_instance_method method, &b
    p "overriding instance method #{method} in #{self}"
    alias_method "_#{method.to_s}".to_sym, method
    self.send :define_method, method, &b
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
