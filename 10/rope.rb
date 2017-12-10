#!/usr/bin/env ruby

require 'enumerator'

EXAMPLE_LENGTHS = [3, 4, 1, 5].freeze
INPUT = '76,1,88,148,166,217,130,0,128,254,16,2,130,71,255,229'

class Rope
    attr_reader :values

    def initialize(length = 256)
        @length = length
        @skip_size = 0
        @total_rotation = 0
        @values = (0...@length).to_a
    end

    def checksum
        @values[0] * @values[1]
    end

    def correct!
        rotation = @length - (@total_rotation % @length)
        @values.rotate! rotation
    end

    def pinch!(length)
        # Reverse the values
        section = @values[0,length]
        @values[0,length] = section.reverse

        # Rotate the values past the reversed part
        rotation = length + @skip_size
        @values.rotate! rotation
        @total_rotation += rotation

        # Increment the skip
        @skip_size += 1
    end

    def print_rope
        # Get the rope rotates back
        rotation = @length - (@total_rotation % @length)
        rotated_values = @values.rotate rotation

        puts rotated_values.inspect
    end
end

class KnotHash
    def initialize
        @rope = Rope.new 256
    end

    def hash!(lengths)
        64.times do
            lengths.each do |length|
                @rope.pinch! length
            end
        end

        @rope.correct!
    end

    def hash_value
        @rope.values
            .each_slice(16)
            .map { |chunk| chunk.reduce(0) { |acc,value| acc ^ value } }
            .map { |value| "%02x" % value }
            .join
    end
end

# Example run
rope = Rope.new 5
rope.print_rope

EXAMPLE_LENGTHS.each do |length|
    rope.pinch! length
    rope.print_rope
end

rope.correct!
puts "Example: #{rope.checksum}"

# Part 1
rope = Rope.new 256
rope.print_rope

input_lengths = INPUT.split(',').map(&:to_i)
input_lengths.each do |length|
    rope.pinch! length
    rope.print_rope
end

rope.correct!
puts "Input: #{rope.checksum}"

# Part 2
input_lengths = INPUT.each_byte.to_a
input_lengths += [17, 31, 73, 47, 23]

knot_hash = KnotHash.new
knot_hash.hash! input_lengths

puts "Hashed: #{knot_hash.hash_value}"