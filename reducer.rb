module Reducer
  def self.run(tree, threshold)
    size, files = tree.size, tree.files

    significant_subdirectories = []
    tree.subdirectories.each do |node|
      reduced_node = run(node, threshold)
      if reduced_node.size >= threshold or not reduced_node.subdirectories.empty?
        significant_subdirectories << reduced_node
      else
        size += reduced_node.size
        files += reduced_node.files
      end
    end

    new_tree = DirectoryNode.new(tree.path, size, files)
    significant_subdirectories.each {|n| new_tree.add_subdirectory(n)}
    return new_tree
  end
end
