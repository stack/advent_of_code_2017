#!/usr/bin/env ruby

class Enhancer
  attr_reader :image

  def initialize(image, rules)
    @image = image
    @rules = rules
  end

  def run(times)
    # Do nothin if there are no runs left
    return if times.zero?

    puts 'Current Image:'
    @image.print_image
    puts

    subimages = @image.subimages

    puts 'Subimages:'
    subimages.each do |subimage|
      subimage.print_image
      puts
    end

    new_subimages = subimages.map do |subimage|
      @rules.find { |rule| rule.matches? subimage }.output
    end

    puts 'New Subimages:'
    new_subimages.each do |subimage|
      subimage.print_image
      puts
    end

    @image = Image.combined new_subimages

    puts 'Combined:'
    @image.print_image
    puts
          
    # Recurse
    run(times - 1)
  end
end

class Image
  def initialize(size)
    @data = Array.new(size) { Array.new(size, '.') }
  end

  def self.combined(subimages)
    size = Math.sqrt(subimages.length).to_i
    total_size = size * subimages.first.width

    image = Image.new total_size

    row = 0
    subimages.each_slice(size) do |row_images|
      column = 0

      row_images.each do |subimage|
        start_x = subimage.width * column
        start_y = subimage.height * row

        subimage.width.times do |x|
          subimage.height.times do |y|
            image[start_x + x, start_y + y] = subimage[x,y]
          end
        end

        column += 1
      end

      row += 1
    end

    image
  end

  def self.parse(data)
    size = data.count('/') + 1

    image = Image.new size
    image.parse_string data

    image
  end

  def self.from_image(source_image, x_offset, y_offset, size)
    image = Image.new size

    size.times do |x|
      size.times do |y|
        image[x,y] = source_image[x_offset + x, y_offset + y]
      end
    end

    image
  end

  def [](x, y)
    @data[y][x]
  end

  def []=(x, y, value)
    @data[y][x] = value
  end

  def eql?(other)
    self.to_s == other.to_s
  end

  def hash
    self.to_s.hash
  end
  
  def h_flipped
    size = @data.count
    image = Image.new size

    size.times do |column|
      alt_column = size - column - 1

      size.times do |y|
        image[alt_column, y] = self[column, y]
      end
    end

    image
  end

  def height
    @data.count
  end

  def on
    @data.reduce(0) { |acc, value| acc + value.count('#') }
  end

  def parse_string(data)
    @data = data.split('/').map { |row| row.split '' }
  end

  def print_image
    puts @data.map { |row| row.join '' }.join("\n")
  end

  def rotated
    size = @data.count
    image = Image.new size

    if size == 2
      image[0, 0] = self[0, 1]
      image[0, 1] = self[1, 1]
      image[1, 0] = self[0, 0]
      image[1, 1] = self[1, 0]
    elsif size == 3
      image[0,  0] = self[0, 2]
      image[0,  1] = self[1, 2]
      image[0,  2] = self[2, 2]
      image[1,  0] = self[0, 1]
      image[1,  1] = self[1, 1] 
      image[1,  2] = self[2, 1]
      image[2,  0] = self[0, 0]
      image[2,  1] = self[1, 0]
      image[2,  2] = self[2, 0]
    else
      raise "Rotation not implemented for size #{size}"
    end

    image
  end

  def to_s
    @data.map { |row| row.join '' }.join('/')
  end

  def v_flipped
    size = @data.count
    image = Image.new size

    size.times do |row|
      alt_row = size - row - 1

      size.times do |x|
        image[x, alt_row] = self[x, row]
      end
    end

    image
  end

  def subimages
    if @data.count % 2 == 0
      subimages_sized 2
    elsif @data.count % 3 == 0
      subimages_sized 3
    else
      raise "Cannot generate subimages from a size of #{@data.count}"
    end
  end

  def width
    @data.first.count
  end

  private

  def subimages_sized(size)
    subimages = []

    subsize = @data.count / size
    subimage_size = @data.count / subsize

    puts "Getting subimages for size #{subsize} - #{subimage_size}"

    subsize.times do |y_section|
      subsize.times do |x_section|
        x_start = x_section * size
        y_start = y_section * size

        puts "Getting subimage #{x_section},#{y_section} from #{x_start},#{y_start} - #{subsize}"

        subimages << Image.from_image(self, x_start, y_start, size)
      end
    end

    subimages
  end
end

class Rule
  attr_reader :output

  def initialize(data, output)
    # Decompose the data into a template
    template = Image.parse data

    # Build space for every variant of the rule
    @variants = []

    # Use each rotation to generate every possible orintation of flipped
    all_rotations(template).each do |variant|
      @variants << variant
      @variants << @variants.last.v_flipped
      @variants << @variants.last.h_flipped
      @variants << @variants.last.v_flipped
    end

    # Uniq the variants to cut down on iterations
    @variants.uniq!

    # Create the output image
    @output = Image.parse output
  end

  def matches?(image)
    matches = false

    @variants.each do |variant|
      if variant.eql?(image)
        matches = true
        break
      end
    end

    matches
  end

  def print_rule
    puts "Variants"
    puts "--------"

    @variants.each do |v|
      v.print_image
      puts
    end

    puts "Output"
    puts "------"

    @output.print_image
    puts
  end

  private

  def initialize_data(data)
    # Caluclate the size the rule applies to
    if data.length == 5
      @size = 2
    elsif data.length == 11
      @size = 3
    else
      raise "Invalid rule length: #{data.length}"
    end

    
  end

  def all_rotations(template)
    variants = []

    variants << template.dup
    variants << variants.last.rotated
    variants << variants.last.rotated
    variants << variants.last.rotated

    variants
  end

  def initialize_output(data)
    # Calculate the size of the output
    if data.length == 11
      @output_size = 3
    elsif data.length == 19
      @output_size = 4
    else
      raise "Invalid rule output length: #{data.length}"
    end

    
  end
end

# Always start with the same image
start_image = Image.parse '.#./..#/###'
rules = ARGF.each_line.map do |line|
  (rule_data, rule_output) = line.chomp.split(' => ')
  Rule.new rule_data, rule_output
end

enhancer = Enhancer.new start_image, rules
enhancer.run 18

puts "Enhancer on: #{enhancer.image.on}"

exit

# Rule parsing tests
rule_string = '.#./..#/### => #..#/..../..../#..#' # '../.# => ##./#../...'
(rule_data, rule_output) = rule_string.split(' => ')
rule = Rule.new rule_data, rule_output

rule.print_rule

exit 

# Rotation testing
image = Image.parse '.#./..#/###'

4.times do
  image.print_image
  puts

  image = image.rotated
end

exit



