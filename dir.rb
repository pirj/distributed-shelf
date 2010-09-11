class Dir
  class << self
    # alias_method :_atime, :atime
    # def atime file
    #   "proxied #{atime.file}"
    # end

    chdir
    
    Dir.delete( string ) => 0
    Dir.rmdir( string ) => 0
    Dir.unlink( string ) => 0

    entries
    
    directory?
    
    foreach(dirname, &b)
    
    getwd
    pwd
    
    mkdir
    
    init (name)
    
    open(name)
    
    open(name, &b)
    
  end
  
  ?close
  
  each &b
  
  path
  
  ?seek
  ?pos
  ?tell
  
  read
  
end