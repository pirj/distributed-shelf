require "file"

p File.atime("file.rb")
p File.ctime("file.rb")
p File.mtime("/remote/file.rb")
p File.delete("/remote/file1", "/remote/file2")
p File.rename("/remote/oldname", "/remote/newname")
p File.truncate("/remote/large", 300)

p File.new("/remote/time").atime
p File.new("/remote/large").truncate 200
p File.new("/remote/interesting").read
p File.new("/remote/empty").write "something"

File.open("/remote/block") do |file|
  p file.read
  p file.truncate 50
end
