module FileUtils
  def mkdir(list, options = {})
    fu_check_options options, OPT_TABLE['mkdir']
    list = fu_list(list)
    fu_output_message "mkdir #{options[:mode] ? ('-m %03o ' % options[:mode]) : ''}#{list.join ' '}" if options[:verbose]
    return if options[:noop]

    list.each do |dir|
      fu_mkdir dir, options[:mode]
    end
  end

  def mkdir_p(list, options = {})
    fu_check_options options, OPT_TABLE['mkdir_p']
    list = fu_list(list)
    fu_output_message "mkdir -p #{options[:mode] ? ('-m %03o ' % options[:mode]) : ''}#{list.join ' '}" if options[:verbose]
    return *list if options[:noop]

    list.map {|path| path.sub(%r</\z>, '') }.each do |path|
      # optimize for the most common case
      begin
        fu_mkdir path, options[:mode]
        next
      rescue SystemCallError
        next if File.directory?(path)
      end

      stack = []
      until path == stack.last   # dirname("/")=="/", dirname("C:/")=="C:/"
        stack.push path
        path = File.dirname(path)
      end
      stack.reverse_each do |dir|
        begin
          fu_mkdir dir, options[:mode]
        rescue SystemCallError => err
          raise unless File.directory?(dir)
        end
      end
    end
  end

  def fu_mkdir(path, mode)
    Dir.mkdir path
  end
end
