#!/usr/bin/env ruby

def print_instructions(instructions, head)
  instructions.each_with_index do |instruction, idx|
    if idx == head
      print "(#{instruction}) "
    else
      print " #{instruction}  "
    end
  end

  print "\n"
end

# Get the input and build the instructions
instructions = ARGF.each_line.map { |line| line.chomp.to_i }
part_1_instructions = instructions.dup

# Run the instructions
head = 0
steps = 0

print_instructions part_1_instructions, head

loop do
  # Read the jump value
  jump_value = part_1_instructions[head]

  # Increment the head value
  part_1_instructions[head] += 1

  # Can we jump?
  head += jump_value
  steps += 1
  break if head < 0
  break if head >= part_1_instructions.count

  # Dump the instructions
  # print_instructions part_1_instructions, head
end

# Done!
print_instructions part_1_instructions, head
puts "Steps: #{steps}"

# Reset!
part_2_instructions = instructions.dup
head = 0
steps = 0

print_instructions part_2_instructions, head

loop do
  # Read the jump value
  jump_value = part_2_instructions[head]

  # Increment the head value
  if jump_value >= 3
    part_2_instructions[head] -= 1
  else
    part_2_instructions[head] += 1
  end

  # Can we jump?
  head += jump_value
  steps += 1
  break if head < 0
  break if head >= part_2_instructions.count

  # Dump the instructions
  # print_instructions part_2_instructions, head
end

# Done!
print_instructions part_2_instructions, head
puts "Steps: #{steps}"
