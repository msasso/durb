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

  def in?(d)
    @path[0..d.path.length-1] == d.path
  end

  def find_subdirectory(d)
    if d.path == @path
      self
    else
      raise ArgumentError, "Cannot find path." if not d.in?(self)
      d.path[@path.length]
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

  def dump(io = "", indentation = 0)
    io << "%s(%s %d %d %d" % [' ' * indentation, self.path_string.inspect, @size, @files, @subdirectories.size]
    io << "\n" + self.significant_subdirectories.map{|n| n.dump("", indentation+2)}.join("\n") \
          if not self.significant_subdirectories.empty?
    io << ")"
    io << "\n" if indentation == 0
    io
  end

  def self.read(io)
    ddp = DirectoryDataParser.new
#     x = ddp.parse(io)
#     return x
    return (ddp.parse(io) or raise ddp.failure_reason)
  end
end
