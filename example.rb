# todo:remove
$: << File.join(File.dirname(__FILE__), 'lib')
ENV['DISTRIBUTED_SHELF_URL'] = 'http://localhost:8000/storage/g2345hg245g24g42g'

# require 'rubygems'
require 'dshelf'

DistributedShelf::config = {
  :distributed_path => '/remote',
  :storage_url => ENV['DISTRIBUTED_SHELF_URL']
}

File.open('/remote/111/file1.txt', 'wb') do |file|
  file.write('writing to a new remotely stored file')
end

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
stat = File.stat('/remote/111/file1.txt')
p "atime: #{stat.atime}"
p "ctime: #{stat.ctime}"
p "mtime: #{stat.mtime}"

# puts Dir.entries('/remote')
