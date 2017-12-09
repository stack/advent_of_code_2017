#!/usr/bin/env ruby

class Node
    attr_accessor :parent

    def print_node
        raise NotImplementedError
    end

    def garbage
        raise NotImplementedError
    end

    def score(parent_score = 0)
        raise NotImplementedError
    end
end

class GarbageNode < Node
    attr_accessor :data

    def initialize
        @data = ''
    end

    def garbage
        @data.length
    end

    def print_node
        "<#{@data}>"
    end

    def score(parent_score = 0)
        0
    end
end

class GroupNode < Node
    attr_accessor :children

    def initialize
        @children = []
    end

    def garbage
        @children.map(&:garbage).reduce(0, &:+)
    end

    def print_node
        value = '{'
        value += @children.map(&:print_node).join(',')
        value += '}'

        return value
    end

    def score(parent_score = 0)
        child_scores = @children.map { |c| c.score(parent_score + 1) }.reduce(0, &:+)
        parent_score + 1 + child_scores
    end
end

class StreamParser
    def initialize(stream)
        @stream = stream
        @groups = []
        @state = :initial
    end

    def parse!
        # Reset
        @state = :idle
        @root_group = GroupNode.new

        current_group = @root_group
        current_garbage = nil
        skip_next = false

        @stream.each do |datum|
            # We may need to skip this datum
            if skip_next
                raise "Invalid skip request outside of garbage" if current_garbage.nil?
                
                # current_garbage.data += datum

                skip_next = false
                next
            end

            # Handle the datum
            case datum
            when '{'
                if current_garbage.nil?
                    group = GroupNode.new

                    group.parent = current_group
                    current_group.children << group

                    current_group = group
                else
                    current_garbage.data += datum
                end
            when '}'
                if current_garbage.nil?
                    current_group = current_group.parent
                else
                    current_garbage.data += datum
                end
            when '<'
                if current_garbage.nil?
                    garbage = GarbageNode.new

                    garbage.parent = current_group
                    current_group.children << garbage

                    current_garbage = garbage
                else
                    current_garbage.data += datum
                end
            when '>'
                current_garbage = nil
            when '!'
                skip_next = true
            when ','
                current_garbage.data += datum unless current_garbage.nil?
            else
                raise "Got extra data outside of garbage" if current_garbage.nil?
                current_garbage.data += datum
            end
        end
    end

    def garbage_groups
        @root_group.children.map(&:garbage)
    end

    def score_groups
        @root_group.children.map(&:score)
    end

    def print_groups
        puts @root_group.children.map(&:print_node).join('|')
    end
end

# Parse each line
ARGF.each_line do |line|
    data = line.chomp.split ''

    stream = StreamParser.new data
    stream.parse!

    stream.print_groups
    puts "Scores: #{stream.score_groups.inspect}"
    puts "Garbages: #{stream.garbage_groups.inspect}"
end
