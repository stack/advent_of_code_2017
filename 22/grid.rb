#!/usr/bin/env ruby

class Grid
  def initialize
    @nodes = {}

    @current_x = 0
    @current_y = 0

    @min_x = 0
    @max_x = 0
    
    @min_y = 0
    @max_y = 0

    @direction = :up
    @caused_infections = 0
    @caused_cleanups = 0
    @bursts = 0
  end

  def [](x, y)
    key = point_to_key(x, y)
    value = @nodes[key]

    @nodes[key] || '.'
  end

  def []=(x, y, value)
    @min_x = [x, @min_x].min
    @max_x = [x, @max_x].max

    @min_y = [y, @min_y].min
    @max_y = [y, @max_y].max

    key = point_to_key(x, y)
    @nodes[key] = value
  end

  def print_grid
    header_size = @max_x - @min_x + 1

    puts "*-#{'-' * (header_size * 3)}-*"

    (@min_y..@max_y).each do |y|
      print "| "
      (@min_x..@max_x).each do |x|
        value = self[x, y]

        if x == @current_x && y == @current_y
          print "[#{value}]"
        else
          print " #{value} "
        end
      end

      puts " |"
    end

    puts "*-#{'-' * (header_size * 3)}-*"
    puts "Bursts, #{@bursts}, Infections: #{@caused_infections}, Clean ups: #{@caused_cleanups}"
  end

  def burst!
    current_value = self[@current_x, @current_y]

    case current_value
    when '#'
      turn_right
      self[@current_x, @current_y] = '.'
      @caused_cleanups += 1
    when '.'
      turn_left
      self[@current_x, @current_y] = '#'
      @caused_infections += 1
    else
      raise "Invalid current value for inspection: #{current_value}"
    end

    move

    @bursts += 1
  end

  private

  def move
    case @direction
    when :up then @current_y -= 1
    when :right then @current_x += 1
    when :down then @current_y += 1
    when :left then @current_x -= 1
    else
      raise "Invalid direction to move: #{@direction}"
    end
  end

  def point_to_key(x, y)
    "#{x},#{y}"
  end

  def turn_left
    @direction = case @direction
    when :up then :left
    when :right then :up
    when :down then :right
    when :left then :down
    else
      raise "Invalid direction to turn left: #{@direction}"
    end
  end

  def turn_right
    @direction = case @direction
    when :up then :right
    when :right then :down
    when :down then :left
    when :left then :up
    else
      raise "Invalid direction to turn right: #{@direction}"
    end
  end
end

grid = Grid.new

initial_state = ARGF.each_line.map do |line|
  line.chomp.split('')
end

initial_width = initial_state.first.count
initial_height = initial_state.count

initial_height.times do |x|
  initial_width.times do |y|
    offset_x = x - (initial_width / 2)
    offset_y = y - (initial_height / 2)

    grid[offset_x, offset_y] = initial_state[y][x]
  end
end

grid.print_grid

10000.times do
  grid.burst!
  # grid.print_grid
end

grid.print_grid
