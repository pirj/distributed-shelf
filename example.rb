# todo:remove
$: << File.join(File.dirname(__FILE__), 'lib')
ENV['DISTRIBUTED_SHELF_URL'] = 'http://localhost:8000/storage/g2345hg245g24g42g'

# require 'rubygems'
require 'dshelf'

DistributedShelf::config = {
  :distributed_path => '/remote',
  :storage_url => ENV['DISTRIBUTED_SHELF_URL']
}

p "Dir.pwd #{Dir.pwd}"
p "Dir.mkdir local #{Dir.mkdir('/tmp/1')}"
p "Dir.mkdir remote #{Dir.mkdir('/remote/111/')}"

p "entries local #{Dir.entries('/tmp/1')}"
p "entries remote #{Dir.entries('/remote/111/')}"

p "Dir.chdir remote #{Dir.chdir('/remote/111/')}"
p "Dir.pwd #{Dir.pwd}"
p "Dir.chdir local #{Dir.chdir('/tmp')}"

p "Dir.rmdir local #{Dir.rmdir('/tmp/1')}"
p "Dir.rmdir remote #{Dir.rmdir('/remote/111/')}"


p "nonexisting exists? #{File.exists?('/remote/111/file2.txt')}"

File.open('/remote/111/file1.txt', 'wb') do |file|
  file.write('writing to a new remotely stored file')
end

p "existing exists? #{File.exists?('/remote/111/file1.txt')}"

File.open('/remote/111/file1.txt') do |file|
  p "readall:[#{file.read}]"
end

File.open('/remote/111/file1.txt') do |file|
  x = file.read 10
  p "read 10:[#{x}]"
end

File.open('/remote/111/file1.txt') do |file|
  x = file.read 10, 3
  p "read 10,3:[#{x}]"
end

p "size=#{File.size('/remote/111/file1.txt')}"

p File.truncate('/remote/111/file1.txt', 20)
p "size=#{File.size('/remote/111/file1.txt')}"
p File.new('/remote/111/file1.txt', 'rb').read

stat = File.stat('/remote/111/file1.txt')
p "zero?: #{stat.zero?}"
p "atime: #{stat.atime}"
p "ctime: #{stat.ctime}"
p "mtime: #{stat.mtime}"
p "file?: #{stat.file?}"
p "directory?: #{stat.directory?}"
p "symlink?: #{stat.symlink?}"
p "readable?: #{stat.readable?}"
p "writable?: #{stat.writable?}"

stat = File.new('/remote/111/file1.txt').stat
p "zero?: #{stat.zero?}"
p "atime: #{stat.atime}"
p "ctime: #{stat.ctime}"
p "mtime: #{stat.mtime}"
p "file?: #{stat.file?}"
p "directory?: #{stat.directory?}"
p "symlink?: #{stat.symlink?}"
p "readable?: #{stat.readable?}"
p "writable?: #{stat.writable?}"

p "file?: #{File.file?('/remote/111')}"
p "directory?: #{File.directory?('/remote/111')}"
p "symlink?: #{File.symlink?('/remote/111')}"
p "readable?: #{File.readable?('/remote/111')}"
p "writable?: #{File.writable?('/remote/111')}"

p "rename : #{File.rename('/remote/111/file1.txt', '/remote/111/file2.txt')}"
p "original exists? #{File.exists?('/remote/111/file1.txt')}" # false
p "new exists? #{File.exists?('/remote/111/file2.txt')}" # true

p "link exists? #{File.exists?('/remote/111/file3.txt')}" # false
p "symlink exists? #{File.exists?('/remote/111/file4.txt')}" # false

p "creating link #{File.link('/remote/111/file2.txt', '/remote/111/file3.txt')}"
p "link exists? #{File.exists?('/remote/111/file3.txt')}" # true

p "creating symlink #{File.symlink('/remote/111/file2.txt', '/remote/111/file4.txt')}"
p "symlink exists? #{File.exists?('/remote/111/file4.txt')}" # true

p "removing : #{File.delete('/remote/111/file4.txt', '/remote/111/file3.txt', '/remote/111/file2.txt')}"
p "exists? #{File.exists?('/remote/111/file2.txt')}"
p "exists? #{File.exists?('/remote/111/file3.txt')}"
p "exists? #{File.exists?('/remote/111/file4.txt')}"

# puts Dir.entries('/remote')
