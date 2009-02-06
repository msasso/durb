module Reducer
  def self.run(tree, threshold)
    rtree = DirectoryNode.new(tree.path, tree.size, tree.files)

    tree.subdirectories.each{|n| rtree.add_subdirectory(run(n, threshold))}
    rtree.insignificant_subdirectories.each do |n|
      rtree.size += n.size
      rtree.files += n.files
    end
    rtree.significant = (rtree.size >= threshold or not rtree.significant_subdirectories.empty?)

    return rtree
  end
end
