#!/usr/bin/env ruby

class HexWalker
    attr_accessor :x, :y
    attr_accessor :max_displacement

    def initialize
        @x = 0
        @y = 0

        @max_displacement = 0
    end

    def displacement
        x = @x.abs
        y = @y.abs
        steps = 0

        while x != 0 || y != 0
            x -= 1 if x != 0
            y -= 1 if y != 0

            steps += 1
        end

        steps
    end

    def walk!(direction)
        case direction
        when :n
            @y -= 1
        when :ne
            @x += 1
            @y -= 1
        when :se
            @x += 1
        when :s
            @y += 1
        when :sw
            @x -= 1
            @y += 1
        when :nw
            @x -= 1
        else
            raise "Invalid walking direction: #{direction}"
        end

        @max_displacement = [@max_displacement, displacement].max
    end
end

ARGF.each_line do |line|
    directions = line.chomp.split(',').map(&:to_sym)

    walker = HexWalker.new
    directions.each do |direction|
        walker.walk! direction
    end

    puts "Displacement: #{walker.displacement}"
    puts "Max Displacement: #{walker.max_displacement}"
end
