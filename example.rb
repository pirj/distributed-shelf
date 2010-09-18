# todo:remove
$: << File.join(File.dirname(__FILE__), 'lib')
ENV['DISTRIBUTED_SHELF_URL'] = 'http://localhost:8000/storage'

# require 'rubygems'
require 'dshelf'

DistributedShelf::config = {
  :distributed_path => '/remote',
  :storage_url => ENV['DISTRIBUTED_SHELF_URL']
}

File.open('/remote/file1.txt', 'wb') do |file|
  file.write('writing to a new remotely stored file')
end

# File.open('/remote/file1.txt', 'wb') do |file|
#   p file.read.size
# end

# puts Dir.entries('/remote')
