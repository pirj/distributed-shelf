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
      p "remote rmdir"
      0
    end
  end

  proxy_method(:entries) do |dir|
    p "remote entries"
  end

  proxy_method(:mkdir) do |dir|
    p "remote mkdir"
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