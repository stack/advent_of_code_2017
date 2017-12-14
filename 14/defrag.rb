#!/usr/bin/env ruby

require 'rubygems'

require 'chunky_png'
require 'fileutils'

require_relative 'knot_hash'

MAGIC_BYTES = [17, 31, 73, 47, 23].freeze

class Grid
    def initialize(key)
        # Don't dump grids by default
        @dump_grid = false

        # Generate the keys for each row
        row_keys = (0..127).map { |x| "#{key}-#{x}" }

        # Generate the hash for each row
        row_hashes = row_keys.map do |key|
            hasher = KnotHash::Hasher.new
            hasher.hash!(key.each_byte.to_a + MAGIC_BYTES)

            hasher.hash_value
        end

        # Convert each row to binary
        row_strings = row_hashes.map { |row| hash_to_binary(row) }
        @rows = row_strings
            .map { |row|
                row
                    .map { |value|
                        value
                            .split('')
                            .map { |v| v == '1' ? '#' : '.' }
                    }
            }
            .flatten
    end

    def detect_regions!(generate_dumps)
        dump_grid 0 if generate_dumps

        region_value = 1

        while index = next_used_square
            puts "Generating region #{region_value}"
            detect_region index, region_value.to_s

            dump_grid region_value if generate_dumps

            region_value += 1
        end

        region_value - 1
    end

    SPACING = 1
    SQUARE_SIZE = 4
    BACKGROUND_COLOR = ChunkyPNG::Color.rgba(192, 192, 192, 255)
    USED_COLOR = ChunkyPNG::Color.rgba(64, 64, 64, 255)
    OPEN_COLOR = ChunkyPNG::Color.rgba(255, 255, 255, 255)
    DETECTED_COLOR = ChunkyPNG::Color.rgba(192, 0, 0, 255)
    CURRENT_COLOR = ChunkyPNG::Color.rgba(255, 255, 0, 255)

    def dump_grid(index)
        width = SPACING + 128 * (SQUARE_SIZE + SPACING)
        height = SPACING + 128 * (SQUARE_SIZE + SPACING)

        width += 1 if width.odd?
        height += 1 if height.odd?

        png = ChunkyPNG::Image.new(width, height, BACKGROUND_COLOR)

        index_value = index.to_s

        128.times do |y|
            128.times do |x|
                idx = y * 128 + x

                start_x = SPACING + (x * (SQUARE_SIZE + SPACING))
                start_y = SPACING + (y * (SQUARE_SIZE + SPACING))
                color = case @rows[idx]
                    when '#' then USED_COLOR
                    when '.' then OPEN_COLOR
                    when index_value then CURRENT_COLOR
                    else
                        DETECTED_COLOR
                    end

                SQUARE_SIZE.times do |x_pos|
                    SQUARE_SIZE.times do |y_pos|
                        png[x_pos + start_x, y_pos + start_y] = color
                    end
                end
            end
        end

        FileUtils.mkdir_p 'dump' unless Dir.exist?('dump')

        file_name = "dump/#{index.to_s.rjust(8, '0')}.png"
        png.save file_name, :fast_rgba
    end

    def print_grid
        @rows.each_slice(128) do |row|
            puts row.join
        end
    end

    def used
        @rows.reduce(0) { |acc, value| acc + (value == '#' ? 1 : 0) }
    end

    private

    def detect_region(index, value)
        frontier = [index]

        until frontier.empty?
            current_index = frontier.shift
            current_row = current_index % 128
            @rows[current_index] = value

            left_index = current_index - 1
            frontier << left_index if get_left(current_index) == '#'

            right_index = current_index + 1
            frontier << right_index if get_right(current_index) == '#'

            above_index = current_index - 128
            frontier << above_index if get_above(current_index) == '#'

            below_index = current_index + 128
            frontier << below_index if get_below(current_index) == '#'

            frontier.uniq!
        end
    end

    def get_above(index)
        # Don't go off of the top side of the grid
        above_index = index - 128
        return nil if above_index < 0

        # Get the actual value
        @rows[above_index]
    end

    def get_below(index)
        # Don't go off of the bottom side of the grid
        below_index = index + 128
        return nil if below_index >= @rows.count

        # Get the actual value
        @rows[below_index]
    end

    def get_left(index)
        # Don't go off of the left side of the grid
        return nil if index % 128 == 0

        # Don't go off of the end of the world
        left_index = index - 1
        return nil if left_index < 0

        # Get the actual value
        @rows[left_index]
    end

    def get_right(index)
        # Don't go off of the right side of the grid
        return nil if index % 128 == 127

        # Don't go off of the end of the world
        right_index = index + 1
        return nil if right_index >= @rows.count

        # Get the actual value
        @rows[right_index]
    end

    def next_used_square
        @rows.index '#'
    end

    def hash_to_binary(hash)
        hash
            .split('')
            .map { |x| "0x0#{x}" }
            .map { |x| x.to_i(16) }
            .map { |x| x.to_s(2).rjust(4, '0') }
    end
end

input = ARGF.read.chomp

grid = Grid.new input

used_squares = grid.used
regions = grid.detect_regions! true

puts "Usage: #{used_squares}"
puts "Regions: #{regions}"