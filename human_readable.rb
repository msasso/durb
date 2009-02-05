module HumanReadable
  SUFFIXES = [' ', 'k', 'm', 'g', 't', 'p']

  def text_to_size(text)
    number, multiplier = text.match(/^(\d+)(\D)?$/)[1..-1]
    exp = multiplier ? SUFFIXES.index(multiplier) : 0
    raise ArgumentError, "Unknown suffix: %s" % multiplier if not exp

    return number.to_i * 1024**exp
  end

  def size_to_text(size)
    exp = 0
    while size > 999
      size /= 1024.0
      exp += 1
    end

    if size >= 100 or exp == 0
      "%d%s" % [size.round, SUFFIXES[exp]]
    elsif size >= 10
      "%.1f%s" % [size, SUFFIXES[exp]]
    else
      "%.2f%s" % [size, SUFFIXES[exp]]
    end
  end
end
