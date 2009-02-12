class DirectoryNode
  attr_reader :path, :subdirectories
  attr_accessor :size, :files, :subsize, :subfiles, :significant

  def initialize(path, size, files, significant = true)
    @path = path
    @size = size
    @files = files
    @subsize = @subfiles = 0
    @significant = significant
    @subdirectories = []
  end

  def add_subdirectory(d)
    @subdirectories << d
    if d.significant
      @subsize += d.size + d.subsize
      @subfiles += d.files + d.subfiles
    end
  end

  def significant_subdirectories
    @subdirectories.select{|n| n.significant}
  end

  def insignificant_subdirectories
    @subdirectories.select{|n| not n.significant}
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
