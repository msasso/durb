class DirectoryNode
  attr_reader :path, :size, :files, :subdirectories, :subsize, :subfiles

  def initialize(path, size, files)
    @path = path
    @size = size
    @files = files
    @subsize = @subfiles = 0
    @subdirectories = []
  end

  def add_subdirectory(d)
    @subdirectories << d
    @subsize += d.size + d.subsize
    @subfiles += d.files + d.subfiles
  end

  def path_string
    self.class.path_to_string(@path)
  end

  def self.path_to_string(path)
    path.length == 0 ? '/' : ('/' + path.join('/') + '/')
  end

  def self.string_to_path(path_string)
    path_string == '/' ? [] : path_string.split('/').reject{|component| component.empty?}
  end
end
