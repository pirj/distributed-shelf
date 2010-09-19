class Dir
  class << self
    include DistributedShelf
  end

  class << self

    # chdir
    # 
    # Dir.delete( string ) => 0
    # Dir.rmdir( string ) => 0
    # Dir.unlink( string ) => 0
    # 
    # entries
    # 
    # directory?
    # 
    # foreach(dirname, &b)
    # 
    # getwd
    # pwd
    # 
    # mkdir
    # 
    # init (name)
    # 
    # open(name)
    # 
    # open(name, &b)
    # 
  end
  
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