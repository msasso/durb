class DirectoryInspector
  def initialize(path, options = {})
    @path = DirectoryNode.string_to_path(path)
    @filesystem = options["--one-filesystem"] ? File.stat(path).dev : nil
  end

  def run
    make_node(@path)
  end

protected
  def make_node(path)
    size, files, subdirectories = inspect(path)

    dir = DirectoryNode.new(path, size, files)
    subdirectories.map{|p| make_node(p)}.select{|n| not n.nil?}.each do |n|
      dir.add_subdirectory(n)
    end

    return dir
  end

  def inspect(path)
    path_string = DirectoryNode.path_to_string(path)
    size = files = 0
    subdirectories = []

    begin
      dir = Dir.new(path_string)
    rescue Errno::EACCES
      raise $!
    rescue Errno::ENOENT
      raise $!
    end
    dir.each do |f|
      next if [".", ".."].include?(f)
      fname = path_string + f
      begin
        st = File.lstat(fname)
      rescue Errno::EACCES
        raise $!
      rescue Errno::ENOENT, Errno::ELOOP
        next
      end
      next if st.symlink?
      next if @filesystem and st.dev != @filesystem
      if st.file?
        size += (512 * st.blocks)
        files += 1
      elsif st.directory?
        # Need to add directory size?
        subdirectories << path + [f]
      end
    end

    return size, files, subdirectories
  end
end
