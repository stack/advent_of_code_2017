#!/usr/bin/env ruby

class TowerNode
    attr_reader :name
    attr_reader :weight
    attr_reader :child_names

    attr_reader :children
    attr_accessor :parent

    def initialize(name, weight, child_names = [])
        @name = name
        @weight = weight
        @child_names = child_names

        @children = []
        @parent = nil
    end

    def add_child(node)
        @children << node
        node.parent = self
    end

    def find_unbalanced
        # Find the children that are unbalanced
        unbalanced = @children.find_all { |child| child.unbalanced? }

        # If children are unbalanced, we're unbalanced
        return self if unbalanced.empty?

        # We should only have one unbalanced child
        puts "#{unbalanced.inspect}"
        raise 'Too many unbalanced children' if unbalanced.count != 1

        # See if the child is the on that's unbalanced
        return unbalanced.first.find_unbalanced
    end

    def inspect
        value = "#{@name} (#{@weight})"
        value += " -> #{@children.map(&:name).join(', ')}" unless @children.empty?
        value += " <- #{@parent.name}" unless @parent.nil?

        value
    end

    def print_tree(level = 1)
        puts "#{'-' * level} #{name} (#{@weight}, #{total_weight})"
        @children.each do |child|
            child.print_tree level + 1
        end
    end

    def total_weight
        @cached_total_weight ||= @weight + @children.map(&:total_weight).reduce(0, &:+)
    end

    def unbalanced?
        child_weights = @children.map(&:total_weight)
        unique_child_weights = child_weights.uniq

        unique_child_weights.count != 1
    end

    def unbalanced_child
        total_weights = @children.map(&:total_weight)
        bad_child = nil

        @children.each do |child|
            matches = total_weights.find_all { |x| x == child.total_weight }
            if matches.count == 1
                bad_child = child
                break
            end
        end

        # All of the children are balanced, so this node is the bad one
        return self if bad_child.nil?
        return bad_child.unbalanced_child
    end
end

# Read the input and convert it to nodes
nodes = {}

ARGF.each_line do |line|
    name = ''
    weight = 0

    if /^([a-z]+) \((\d+)\)/ =~ line
        name = $1
        weight = $2.to_i
    else
        $stderr.puts "Could not parse name and weight from the line '#{line}'"
        next
    end

    child_names = []
    if /-> (.+)$/ =~ line
        child_names = $1.gsub(' ', '').split(',')
    end

    # Sanity check
    raise 'Name is required' if name.nil?

    # puts "Found #{name} (#{weight}) -> #{child_names.inspect}"
    nodes[name] = TowerNode.new(name, weight, child_names)
end

# Link all of the children
nodes.each do |name, node|
    node.child_names.each do |child_name|
        child_node = nodes[child_name]
        raise 'Child not found' if child_node.nil?

        node.add_child child_node
    end
end

# Find the node that doesn't have a parent
root_node = nodes.values.find { |node| node.parent.nil? }
puts "Root: #{root_node.inspect}"

root_node.print_tree

unbalanced_node = root_node.find_unbalanced
puts "Unbalanced Node: #{unbalanced_node.inspect}"

unbalanced_node.print_tree

unbalanced_child = unbalanced_node.unbalanced_child
puts "Unbalanced Child: #{unbalanced_child.inspect}"

balanced_weight = unbalanced_node.children.reject { |child| child.name == unbalanced_child.name }.uniq.first.total_weight
diff = unbalanced_child.total_weight - balanced_weight

puts "Difference - Balanced: #{balanced_weight}, Unbalanced: #{unbalanced_child.total_weight} - #{diff}"
puts "Correct weight: #{unbalanced_child.weight - diff}"

# diff = other_weight - unbalanced_child.total_weight
# adjusted_weight = unbalanced_child.weight + diff

# puts "Difference - Others: #{other_weight} vs. Unbalanced: #{unbalanced_child.total_weight}"
# puts "Weight should be #{adjusted_weight}"