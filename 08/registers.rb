#!/usr/bin/env ruby

class Registers
    attr_reader :highest_value

    def initialize
        @registers = {}
        @highest_value = -(2**(0.size * 8 -2))
    end

    def [](name)
        @registers[name] || 0
    end

    def []=(name, value)
        @registers[name] = value
        @highest_value = [@highest_value, value].max
    end

    def largest_value
        @registers.values.max
    end

    def print_registers
        @registers.keys.sort.each do |key|
            puts "#{key.lpad(3, ' ')}: #{@registers[key]}"
        end
    end

    def reset
        @registers = {}
    end
end

class Instruction
    attr_reader :name
    attr_reader :op
    attr_reader :amount

    attr_reader :condition_lhs
    attr_reader :condition_op
    attr_reader :condition_rhs

    def initialize(name, op, amount, condition_lhs, condition_op, condition_rhs)
        @name = name.to_sym
        @op = op.to_sym
        @amount = amount.to_i
        @condition_lhs = condition_lhs.to_sym
        @condition_op = condition_op
        @condition_rhs = condition_rhs.to_i
    end

    def inspect
        "#{@name} #{@op} #{@amount} if #{@condition_lhs} #{@condition_op} #{@condition_rhs}"
    end
end

# Read the instructions
instructions = ARGF.each_line.map do |line|
    parts = line.chomp.split ' '

    raise "Invalid instruction line: #{line} (#{parts.count})" if parts.count != 7

    Instruction.new parts[0], parts[1], parts[2], parts[4], parts[5], parts[6]
end

# Sanity check
instructions.each { |i| puts i.inspect }

# Run the code
registers = Registers.new
instructions.each do |instruction|
    # Check the condition first
    condition_value = registers[instruction.condition_lhs]

    perform_operation = case instruction.condition_op
    when '=='
        condition_value == instruction.condition_rhs
    when '!='
        condition_value != instruction.condition_rhs
    when '>='
        condition_value >= instruction.condition_rhs
    when '<='
        condition_value <= instruction.condition_rhs
    when '>'
        condition_value > instruction.condition_rhs
    when '<'
        condition_value < instruction.condition_rhs
    else
        raise "Unhandled condition operation: #{instruction.condition_op}"
    end

    # Keep going?
    next unless perform_operation

    # Perform the operation
    case instruction.op
    when :inc
        registers[instruction.name] += instruction.amount
    when :dec
        registers[instruction.name] -= instruction.amount
    else
        raise "Unhandled operation: #{instruction.op}"
    end
end

# Done
puts "Largest value: #{registers.largest_value}"
puts "Highest value: #{registers.highest_value}"
