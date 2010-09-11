require 'file'

p File.mtime('/remote/file1.txt')
p File.rename('/remote/file1.txt', '/remote/file2.txt')

p File.new('/remote/file1.txt').atime
p File.new('/remote/file2.txt').ctime
p File.rename('/remote/file2.txt', '/remote/file1.txt')
p c=File.new('/remote/file1.txt').read
p File.new('/remote/file3.txt').write c

File.open('/remote/file3.txt') do |file|
  p file.read
  p file.truncate 50
end
p File.delete('/remote/file2.txt', '/remote/file3.txt')
