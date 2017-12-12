#!/usr/bin/env ruby

class Node
    attr_accessor :id
    attr_accessor :links

    def initialize(id)
        @id = id
        @links = []
    end

    def add_link(id)
        @links << id
        @links.sort!.uniq!
    end
end

class Village
    def initialize
        @nodes = []
    end

    def group_members(id)
        frontier = [id]
        visited = {id => true}
        members = []

        until frontier.empty?
            current = frontier.shift
            members << current

            @nodes[current].links.each do |link_id|
                next if visited.key? link_id
                frontier << link_id
                visited[link_id] = true
            end
        end

        members
    end

    def group_size(id)
        group_members(id).count
    end

    def total_groups
        frontier = @nodes.compact.map(&:id)

        visited = {}
        frontier.each { |id| visited[id] = true }

        count = 0

        until frontier.empty?
            # Count this as a group
            current = frontier.shift
            count += 1

            # Remove all group members from the frontier
            members = group_members current
            frontier -= members
        end

        count
    end

    def parse_input!(input)
        if /(\d+) <-> (.+)/ =~ input
            id = $1.to_i
            links = $2.split(', ').map(&:to_i)

            if @nodes[id].nil?
                @nodes[id] = Node.new id
            end

            links.each do |link_id|
                if @nodes[link_id].nil?
                    @nodes[link_id] = Node.new link_id
                end

                @nodes[id].add_link link_id
                @nodes[link_id].add_link id
            end
        else
            raise "Cannot parse input: \"#{input}\""
        end
    end

    def print_village
        @nodes.each do |node|
            puts "#{node.id} <-> #{node.links.join ', '}"
        end
    end
end

village = Village.new

ARGF.each_line do |line|
    village.parse_input!(line.chomp)
end

# village.print_village
size = village.group_size 0
puts "Group 0 size: #{size}"

total_groups = village.total_groups
puts "Total groups: #{total_groups}"