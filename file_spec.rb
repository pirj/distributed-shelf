require 'file'

describe File, ' should perform operations' do
  it 'gets props from remote' do
    File.mtime('/remote/file1.txt').class.should == Time
  end
  
  it 'renames files' do
    File.size('/remote/file1.txt').should == 14
    File.rename('/remote/file1.txt', '/remote/file2.txt')
    lambda {File.size('/remote/file1.txt')}.should raise_error(Errno::ENOENT)
    File.size('/remote/file2.txt').should == 14
    File.rename('/remote/file2.txt', '/remote/file1.txt')
  end
end

describe File, ' should perform block operations' do
  it 'gets props from remote' do
    File.new('/remote/file1.txt') do |file|
      file.mtime.class.should == Time
      file.size.should == 14
    end
  end
end

describe File, ' should work with contents' do
  it 'read files' do
    contents = File.new('/remote/file1.txt').read
    contents.size.should == 14
    File.new('/remote/file3.txt').write contents
  end

  it 'write files' do
    contents = File.new('/remote/file1.txt').read
    contents.size.should == 14
    File.new('/remote/file3.txt', "w").write contents
    File.size('/remote/file3.txt').should == 14
  end
end

describe File, ' should work with symlinks' do
  it 'create symlink' do
    File.symlink('/remote/file3.txt', '/remote/file4.txt')
  end
end

describe File, ' should remove files' do
  it 'delete files' do
    File.exists?('/remote/file3.txt').should == true
    File.exists?('/remote/file4.txt').should == true
    File.delete('/remote/file3.txt', '/remote/file4.txt')
    File.exists?('/remote/file3.txt').should == false
    File.exists?('/remote/file4.txt').should == false
  end
end
