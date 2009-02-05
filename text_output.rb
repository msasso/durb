class TextOutput
  def initialize(tree, output, options = {})
    @width = calc_width(tree) + (options[:verbose] ? 23 : 11)
    @output = output
    if output.tty?
      begin
        tput = open("|tput cols")
        max_width = tput.gets.to_i
      rescue
        max_width = 80
      end
      @width = [max_width, @width].min
    end
    @tree = tree
    @options = options
  end

  def print_all(size)
    if @options[:verbose]
      heading = "SELF    SUBS/#   "
      puts((" " * (@width - heading.size - 2)) + heading)
    end
    print_tree(@tree, size)
  end

  def print_tree(tree, size, indentation = 0)
    print_node(tree, size, indentation)
    tree.subdirectories.each do |n|
      print_tree(n, size, indentation + 2)
    end
  end

  def print_node(node, size, indentation)
    if $verbose
      subsize_text = size_to_text(node.subsize)
      if node.subsize == 0 and node.size == 0
        size_text = nil; raise "can this happen?"
      elsif node.subsize == 0
        size_text = "%5s             " % size_to_text(node.size)
      elsif node.size == 0
        size_text = "        %5s/%-4d" % [size_to_text(node.subsize), node.subdirectories.size]
      else
        size_text = "%5s + %5s/%-4d" % [size_to_text(node.size), size_to_text(node.subsize), node.subdirectories.size]
      end
    else
      total_size = node.size #+ node.subsize
      size_text = total_size < size ? nil : size_to_text(total_size)
    end
    align((' ' * indentation) + node.path_string, size_text)
  end

  def calc_width(tree, indentation = 0)
    (tree.subdirectories.map{|n| calc_width(n, indentation + 2)} + [tree.path_string.size + indentation]).max
  end

  def align(left, right)
    right = "" if not right
    size = @width - (left.size + right.size + 4)
    if size <= 0
      left = left[0..(size-4)] + '...'
      size = 0
    end
    @output.print left, ' '
    if not right.empty?
      y = 0
      while size > 0
        @output.print(((y + left.size) % 2 == 0) ? '.' : ' ')
        size -= 1
        y += 1
      end
      @output.print ' ', right
    end
    @output.print "\n"
  end
end