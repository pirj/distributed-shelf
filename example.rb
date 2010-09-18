# todo:remove
$: << File.join(File.dirname(__FILE__), 'lib')
ENV['DISTRIBUTED_SHELF_URL'] = 'http://localhost:8000/storage'

require 'rubygems'
require 'dshelf'

url = ENV['DISTRIBUTED_SHELF_URL']
puts "Connecting to #{url}"

DistributedShelf::config = {
  :distributed_paths => ['/remote']
}

begin
  File.new('/remote/file1.txt', 'wb') do |file|
    file.write('writing to a new remotely stored file')
  end
  
  puts Dir.entries('/remote')
rescue => e
  abort "Failed to access distributed storage: #{e.message}"
end
