#!/usr/bin/env ruby

require 'prime'

class String
  def int_or_sym
    if /-?(\d+)/ =~ self
      self.to_i
    else
      self.to_sym
    end
  end
end

class Coprocessor
  attr_reader :multiplies

  def initialize(instructions)
    @registers = {}
    ('a'..'z').each { |r| @registers[r.to_sym] = 0 }

    @instructions = instructions
    @head = 0
    @multiplies = 0
  end

  def [](register)
    if register.is_a? Integer
      register
    else
      @registers[register]
    end
  end

  def []=(register, value)
    @registers[register] = value
  end

  def print_coprocessor
    register_lines = @registers.keys.sort.map { |key| "#{key}: #{@registers[key]}" }
    instruction_lines = @instructions.each_with_index.map { |instruction, idx|
      "#{idx == @head ? '> ' : '  '} #{instruction}"
    }

    max_instruction_length = instruction_lines.map(&:length).max

    lines = instruction_lines.zip(register_lines).map do |pair|
      lhs = pair[0] || ''
      rhs = pair[1] || ''

      "#{lhs.ljust(max_instruction_length, ' ')} || #{rhs}"
    end

    lines << "Multiplies: #{@multiplies}"

    puts lines.join("\n")
  end

  def run(print_debug = false)
    while @head >= 0 && @head < @instructions.count
      instruction = @instructions[@head]

      case instruction.type
      when :set then set(instruction.op1, instruction.op2)
      when :sub then sub(instruction.op1, instruction.op2)
      when :mul then mul(instruction.op1, instruction.op2)
      when :jnz then jnz(instruction.op1, instruction.op2)
      when :prm then prm(instruction.op1, instruction.op2)
      else
        raise "Unhandled instruction type: #{instruction.type}"
      end

      print_coprocessor if print_debug
    end
  end

  private

  def set(op1, op2)
    self[op1] = self[op2]
    @head += 1
  end

  def sub(op1, op2)
    x = self[op1]
    y = self[op2]

    self[op1] = x - y
    @head += 1
  end

  def mul(op1, op2)
    x = self[op1]
    y = self[op2]

    self[op1] = x * y
    @head += 1
    @multiplies += 1
  end

  def jnz(op1, op2)
    x = self[op1]

    if x != 0
      @head += self[op2]
    else
      @head += 1
    end
  end

  def prm(op1, op2)
    value = self[op2]
    self[op1] = Prime.prime?(value) ? 1 : 0
    @head += 1
  end
end

class Instruction
  attr_reader :type
  attr_reader :op1
  attr_reader :op2

  def initialize(type, op1, op2)
    @type = type
    @op1 = op1
    @op2 = op2
  end

  def self.parse(line)
    if /(.+) (.+) (.+)/ =~ line
      Instruction.new $1.to_sym, $2.int_or_sym, $3.int_or_sym
    else
      raise "Invalid instruction to parse: #{line}"
    end
  end

  def to_s
    "#{@type} #{@op1} #{@op2}"
  end
end

instructions = ARGF.each_line.map do |line|
  Instruction.parse line
end

# Part 1
coprocessor = Coprocessor.new instructions
coprocessor.run
puts "Multiplies: #{coprocessor.multiplies}"

# Part 2
coprocessor = Coprocessor.new instructions
coprocessor[:a] = 1
coprocessor.run true

puts "H: #{coprocessor[:h]}"