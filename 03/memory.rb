#!/usr/bin/env ruby

EXAMPLE_NUMBER = 23
ACTUAL_NUMBER = 347991

class Memory
  def initialize(x_offset, y_offset)
    @width = y_offset.abs * 2 + 1
    @height = x_offset.abs * 2 + 1

    @data = Array.new(@height) { Array.new(@width, 0) }
  end

  def print_memory
    @data.each do |row|
      row.each do |value|
        print "#{value} "
      end

      print "\n"
    end
  end

  def get(x, y)
    (normalized_x, normalized_y) = normalize x, y
    @data[normalized_y][normalized_x]
  end

  def set(x, y, value)
    (normalized_x, normalized_y) = normalize x, y
    @data[normalized_y][normalized_x] = value
  end

  private

  def normalize(x, y)
    normalized_y = (@width - 1) / 2 - y
    normalized_x = (@height - 1) / 2 + x

    [normalized_x, normalized_y]
  end
end

def offset(directions, value)
  x_offset = 0
  y_offset = 0

  0.upto(value - 2) do |i|
    case directions[i]
    when :l then x_offset -= 1
    when :r then x_offset += 1
    when :u then y_offset += 1
    when :d then y_offset -= 1
    end
  end

  [x_offset, y_offset]
end

def generate_directions(final_value)
  directions = []
  current_direction = :d

  i = 1
  loop do
    shifts = i / 2

    shifts.times do
      directions << current_direction
    end

    break if directions.count >= final_value

    i += 1

    current_direction = case current_direction
                        when :r then :u
                        when :u then :l
                        when :l then :d
                        when :d then :r
                        end
  end

  directions
end


# Generate all of the numbers
directions = generate_directions ACTUAL_NUMBER

# --- Part 1 ---

# Example values
(x, y) = offset directions, 12
total = x.abs + y.abs
puts "12: #{x}, #{y} = #{total}"

(x, y) = offset directions, 23
total = x.abs + y.abs
puts "23: #{x}, #{y} = #{total}"

(x, y) = offset directions, 1024
total = x.abs + y.abs
puts "1024: #{x}, #{y} = #{total}"

# Actual value
(x, y) = offset directions, ACTUAL_NUMBER
total = x.abs + y.abs
puts "#{ACTUAL_NUMBER}: #{x}, #{y} = #{total}"

# --- Part 2 ---

# Generate all offsets -> numbers
(x, y) = offset directions, ACTUAL_NUMBER
memory = Memory.new 50, 50
memory.set 0, 0, 1

2.upto(ACTUAL_NUMBER) do |i|
  (x, y) = offset directions, i
  puts "Step #{i}, Offset: #{x}, #{y}"

  neighbors = []
  neighbors << memory.get(x - 1, y - 1)
  neighbors << memory.get(x - 1, y)
  neighbors << memory.get(x - 1, y + 1)
  neighbors << memory.get(x, y - 1)
  neighbors << memory.get(x, y + 1)
  neighbors << memory.get(x + 1, y - 1)
  neighbors << memory.get(x + 1, y)
  neighbors << memory.get(x + 1, y + 1)

  puts "Step #{i}, Neighbors: #{neighbors}"

  sum = neighbors.reduce(&:+)

  puts "Step #{i}, Sum: #{sum}"

  if sum > ACTUAL_NUMBER
    puts sum
    break
  end

  memory.set x, y, sum
end
