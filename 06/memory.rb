#!/usr/bin/env ruby

class Memory
  def initialize(banks)
    @banks = banks.dup
  end

  def balance!
    steps = 0
    previous_values = []

    until previous_values.include?(@banks) do
      previous_values << @banks.dup
      print_banks

      # Extract the value from the bank
      index = most_blocks
      count = @banks[index]
      @banks[index] = 0

      # Redistribute
      count.times do
        index = (index + 1) % @banks.count
        @banks[index] += 1
      end

      steps += 1
    end

    print_banks

    # Find the index of the previous version
    previous_index = previous_values.index @banks

    [steps, previous_values.count - previous_index]
  end

  private

  def most_blocks
    largest = -1
    largest_index = -1

    @banks.each_with_index do |bank, idx|
      if bank > largest
        largest = bank
        largest_index = idx
      end
    end

    largest_index
  end

  def print_banks
    puts @banks.map { |x| x.to_s.rjust(3, ' ') }.join(' ')
  end
end

line = ARGF.read.chomp
banks = line.split(' ').map(&:to_i)

memory = Memory.new banks
(steps, cycle) = memory.balance!

puts "Steps: #{steps}"
puts "Cycle: #{cycle}"
