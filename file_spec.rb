$: << File.join(File.dirname(__FILE__), 'lib')
require 'dshelf'

ENV['DISTRIBUTED_SHELF_URL'] = 'http://localhost:8000/storage/3470e95cc331a9f9eea163f5f41e9483'

DistributedShelf::config = {
  :distributed_path => '/remote',
  :storage_url => ENV['DISTRIBUTED_SHELF_URL']
}

Dir.rmdir('/tmp/storage/3470e95cc331a9f9eea163f5f41e9483/remote') if File.exists?('/tmp/storage/3470e95cc331a9f9eea163f5f41e9483/remote')

describe Dir, ' does not affect local file system' do
  it 'creates/removes dir' do
    Dir.mkdir('/tmp/1').should == 0
    Dir.entries('/tmp/1').should == [".", ".."]
    Dir.rmdir('/tmp/1').should == 0
  end
end

describe Dir, ' remote' do
  it 'creates/removes dir' do
    Dir.mkdir('/remote/').should == 0
    Dir.mkdir('/remote/111/').should == 0
    Dir.entries('/remote/111/').should == [".", ".."]
  end

  it 'changes pwd' do
    Dir.chdir('/remote/111/').should == '/remote/111/'
    Dir.pwd.should == '/remote/111/'
    Dir.chdir('/tmp').should == '/tmp'
    Dir.pwd.should == '/tmp'
  end

  it 'stat' do
    File.zero?('/remote/111').should == false
    File.atime('/remote/111').class.should == Time
    File.ctime('/remote/111').class.should == Time
    File.mtime('/remote/111').class.should == Time
    
    File.file?('/remote/111').should == false
    File.directory?('/remote/111').should == true
    File.symlink?('/remote/111').should == false
    File.readable?('/remote/111').should == true
    File.writable?('/remote/111').should == true
  end
end

describe File, ' operations' do
  it "doesn't allow to acces non-existing files" do
    File.exists?('/remote/111/file2.txt').should == false
  end
  
  it 'writes to a file' do
    File.exists?('/remote/111/file1.txt').should == false
    File.open('/remote/111/file1.txt', 'wb') do |file|
      size = file.write('writing to a new remotely stored file')
      size.should == 37
    end
    File.exists?('/remote/111/file1.txt').should == true
  end

  it 'reads from a file' do
    File.open('/remote/111/file1.txt') do |file|
      data = file.read
      data.should == 'writing to a new remotely stored file'
    end
  end
  
  it 'reads partially' do
    File.open('/remote/111/file1.txt') do |file|
      data = file.read(10)
      data.should == 'writing to'
    end
  end
  
  it 'reads partially with offset' do
    File.open('/remote/111/file1.txt') do |file|
      data = file.read(10, 3)
      data.should == 'ting to a '
    end
  end

  it 'gets size' do
    File.size('/remote/111/file1.txt').should == 37
  end
  
  it 'truncates a file' do
    File.truncate('/remote/111/file1.txt', 20)  
    File.size('/remote/111/file1.txt').should == 20
  end

  it 'gets file stat' do
    stat = File.stat('/remote/111/file1.txt')
    test_stat(stat)
    stat = File.new('/remote/111/file1.txt').stat
    test_stat(stat)
  end

  def test_stat(stat)
    stat.zero?.should == false
    stat.atime.class.should == Time
    stat.ctime.class.should == Time
    stat.mtime.class.should == Time
    stat.file?.should == true
    stat.directory?.should == false
    stat.symlink?.should == false
    stat.readable?.should == true
    stat.writable?.should == true
  end
  
  it 'renames' do
    File.exists?('/remote/111/file2.txt').should == false
    File.rename('/remote/111/file1.txt', '/remote/111/file2.txt').should == 0
    File.exists?('/remote/111/file1.txt').should == false
    File.exists?('/remote/111/file2.txt').should == true
  end

  it 'creates links' do
    File.exists?('/remote/111/file3.txt').should == false
    File.link('/remote/111/file2.txt', '/remote/111/file3.txt').should == 0
    File.exists?('/remote/111/file3.txt').should == true
    File.exists?('/remote/111/file2.txt').should == true
  end
  
  it 'creates symlinks' do
    File.exists?('/remote/111/file4.txt').should == false
    File.symlink('/remote/111/file2.txt', '/remote/111/file4.txt').should == 0
    File.exists?('/remote/111/file4.txt').should == true
    File.exists?('/remote/111/file2.txt').should == true
  end
end

describe Dir, ' entries' do
  it 'get entries' do
    Dir.entries('/remote/111').should == ['.', '..', 'file2.txt', 'file3.txt', 'file4.txt']
  end
end

describe File, ' removal' do
  it 'removes files' do
    File.exists?('/remote/111/file2.txt').should == true
    File.exists?('/remote/111/file3.txt').should == true
    File.exists?('/remote/111/file4.txt').should == true
    File.delete('/remote/111/file4.txt', '/remote/111/file3.txt', '/remote/111/file2.txt').should == true
    File.exists?('/remote/111/file2.txt').should == false
    File.exists?('/remote/111/file3.txt').should == false
    File.exists?('/remote/111/file4.txt').should == false
  end
end

describe Dir, ' removal' do
  it 'removes dirs' do
    File.exists?('/remote/111/').should == true
    Dir.rmdir('/remote/111/').should == 0
    File.exists?('/remote/111/').should == false
  end
  
  it 'refuses removal of non-existing dirs' do
    lambda { Dir.rmdir('/remote/222/') }.should raise_error(Errno::ENOENT)
  end
end
