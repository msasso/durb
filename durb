#!/usr/bin/ruby

require 'getoptlong'

SUFFIXES = [' ', 'k', 'm', 'g']
DEFAULT_SIZE = 100 * 1024 * 1024

tput = open("|tput cols")
$width = tput.gets.to_i
$verbose = false
$filesystem = nil

opts = GetoptLong.new(
  ["--size", "-s", GetoptLong::REQUIRED_ARGUMENT],
  ["--verbose", "-v", GetoptLong::NO_ARGUMENT],
  ["--width", "-w", GetoptLong::REQUIRED_ARGUMENT],
  ["--one-filesystem", "-x", GetoptLong::NO_ARGUMENT])

$path = ARGV[0] ? File.expand_path(ARGV[0]) : File.expand_path(".")

opts.each do |opt, arg|
  case opt
  when "--size"
    $size = arg.to_i * 1024 * 1024
  when "--width"
    $width = arg.to_i
  when "--verbose"
    $verbose = true
  when "--one-filesystem"
    $filesystem = File.stat($path).dev
  end
end

$size = DEFAULT_SIZE if not $size or $size == 0


def dirsize(path = [])
  tree = {:self_size => 0, :sub_size => 0, :self_files => 0, :subs => 0, :sub_files => 0}
  if path.length == 0
    pathstr = '/'
  else
    pathstr = '/' + path.join("/") + '/'
  end

#   puts pathstr
  begin
    dir = Dir.new(pathstr)
  rescue Errno::EACCES
    puts "Perm"
    tree[:self_size] = :unknown
    tree[:self_files] = :unknown
    return tree
  rescue Errno::ENOENT
    return nil
  end
  dir.each do |f|
    next if [".", ".."].include?(f)
    fname = pathstr + f
#     puts fname
    begin
      st = File.lstat(fname)
    rescue Errno::EACCES
      puts "Perm"
      tree[:self_size] = :unknown
      tree[:self_files] = :unknown
      return tree
    rescue Errno::ENOENT, Errno::ELOOP
      next
    end
    next if st.symlink?
    next if $filesystem and st.dev != $filesystem
    if st.file?
      tree[:self_size] += (512 * st.blocks)
      tree[:self_files] += 1
    elsif st.directory?
      # Need to add directory size?
      tree[f] = dirsize(path + [f])
      tree.delete(f) if not tree[f]
    end
  end

  return tree
end

def size(s)
  m = 0

  return "  e " if s < $size

  while s > 999
    s /= 1024.0
    m += 1
  end

  if s < 10 and m != 0
    "%3.1f%s" % [s, SUFFIXES[m]]
  else
    "%3d%s" % [s.round, SUFFIXES[m]]
  end
end

def align(left, right)
  right = "" if not right
  size = $width - (left.size + right.size + 4)
  if size <= 0
    left = left[0..(size-4)] + '...'
    size = 0
  end
  print left, ' '
  if not right.empty?
    y = 0
    while size > 0
      print(((y + left.size) % 2 == 0) ? '.' : ' ')
      size -= 1
      y += 1
    end
    print ' ', right
  end
  print "\n"
end

def printsizeline(name, s, ind = 0)
  if $verbose
    subs = size(s[:sub_size])
    if s[:sub_size] == 0 and s[:self_size] == 0
      sizetext = nil
    elsif s[:sub_size] == 0
      sizetext = "%s            " % size(s[:self_size])
    elsif s[:self_size] == 0
      sizetext = "       %s/%-4d" % [size(s[:sub_size]), s[:subs]]
    else
      sizetext = "%s + %s/%-4d" % [size(s[:self_size]), size(s[:sub_size]), s[:subs]]
    end
  else
    sz = s[:self_size] + s[:sub_size]
    sizetext = sz < $size ? nil : size(sz)
  end
  align((' ' * ind) + name, sizetext)
end

def printsize(s, ind = 0)
  s.each_key do |k|
    next if k.is_a?(Symbol)
    printsizeline(k, s[k], ind)
    printsize(s[k], ind + 2)
  end
end

def reducesize(s)
  s.each_key do |k|
    next if k.is_a?(Symbol)
    reducesize(s[k])
    if s[k][:self_size] < $size and s[k][:sub_size] < $size and s[k].keys.inject(true){|res, x| res and x.is_a?(Symbol)}
      s[:sub_size] += s[k][:self_size]
      s[:subs] += 1
      s[:sub_files] += s[k][:self_files]
      s.delete(k);
    end
  end
end

def calc_width(s, width, ind = 0)
  s.each_key do |k|
    next if k.is_a?(Symbol)
    w = k.size + ind
    width = w if w > width
    w = calc_width(s[k], width, ind + 2)
    width = w if w > width
  end
  width
end

s = dirsize($path.split('/')[1..-1] || [])
reducesize(s);

if $verbose
  heading = "SELF   SUBS/#   "
  puts((" " * ($width - heading.size - 2)) + heading)
end
w = calc_width(s, $path.size, 2) + ($verbose ? 21 : 9)
$width = w if w < $width
printsizeline($path, s)
printsize(s, 2)



