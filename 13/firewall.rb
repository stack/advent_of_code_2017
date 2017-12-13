#!/usr/bin/env ruby

class Layer
    attr_reader :id
    attr_reader :depth

    def initialize(id, depth)
        @id = id
        @depth = depth

        @full_cycle = @depth + (@depth) - 2
    end

    def collision?(time)
        position(time) == 0
    end

    def position(time)
        abs_position = time % @full_cycle
    
        abs_position < @depth ? abs_position : @full_cycle - abs_position
    end

    def severity
        @id * @depth
    end
end

layers = []

ARGF.each_line do |line|
    if /(\d+): (\d+)/ =~ line
        layers << Layer.new($1.to_i, $2.to_i)
    else
        raise "Unmatched line: #{line.comp}"
    end
end

# Run through calculating severity
severity = layers.map { |layer|
    if layer.collision?(layer.id)
        layer.severity
    else
        0
    end
}.reduce(0, &:+)

puts "Severity: #{severity}"

# Find a time where all positions are clear
delay = 0

loop do
    collisions = layers.map { |layer| layer.collision?(layer.id + delay) }
    collision = collisions.reduce(false, &:|)

    break unless collision

    delay += 1
end

puts "Delay: #{delay}"