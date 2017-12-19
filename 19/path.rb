#!/usr/bin/env ruby

class Path
    def initialize(lines)
        @lines = lines

        line_widths = @lines.map(&:count)
        @max_line_width = line_widths.max
    end

    def run
        current_direction = :down
        current_x = start_position
        current_y = 0

        discovered = []
        steps = 1

        loop do
            puts "Current: #{current_x}, #{current_y} - #{current_direction}"
            puts "Discovered: #{discovered.inspect}"

            # Move
            case current_direction
            when :down then current_y += 1
            when :up then current_y -= 1
            when :left then current_x -= 1
            when :right then current_x += 1
            else
                raise "Invalid current direction: #{current_direction}"
            end

            # Break if we're off the edge
            break if current_y < 0 || current_y >= @lines.count
            break if current_x < 0 || current_x >= @max_line_width

            # Read the next value
            next_value = self[current_x, current_y]
            case next_value
            when /([A-Z])/
                raise 'Loop!' if discovered.include?($1)
                discovered << $1
            when '+'
                if current_direction == :up || current_direction == :down
                    if valid_left_right? current_x - 1, current_y
                        current_direction = :left
                    elsif valid_left_right? current_x + 1, current_y
                        current_direction = :right
                    else
                        raise "No place to go from #{current_x}, #{current_y}: #{current_direction}"
                    end
                else
                    if valid_up_down? current_x, current_y - 1
                        current_direction = :up
                    elsif valid_up_down? current_x, current_y + 1
                        current_direction = :down
                    else
                        raise "No place to go from #{current_x}, #{current_y}: #{current_direction}"
                    end
                end
            when ' '
                break
            end

            steps += 1
        end

        [discovered, steps]
    end

    private

    def [](x, y)
        if x < 0 || x >= @max_line_width
            ' '
        elsif y < 0 || y >= @lines.count
            ''
        else
            @lines[y][x]
        end
    end

    def start_position
        @lines.first.index '|'
    end

    def valid_left_right?(x, y)
        value = self[x, y]

        if /[A-Z]/ =~ value
            true
        elsif value == '-'
            true
        else
            false
        end
    end

    def valid_up_down?(x, y)
        value = self[x, y]

        if /[A-Z]/ =~ value
            true
        elsif value == '|'
            true
        else
            false
        end
    end
end

lines = ARGF.each_line.map do |line|
    line.chomp.split('')
end

path = Path.new lines
(discovered, steps) = path.run

puts "Discovered: #{discovered.join ''}"
puts "Steps: #{steps}"