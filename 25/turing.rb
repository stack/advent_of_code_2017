#!/usr/bin/env ruby

class Step
  attr_reader :type
  attr_reader :op

  def initialize(type, op)
    @type = type
    @op = op
  end

  def print_step
    print "    - "

    case @type
    when :write then puts "Write the value #{@op}."
    when :move then puts "Move one slot to the #{@op}."
    when :continue then puts "Continue with state #{@op}."
    else
      raise "Cannot print step type #{@type}"
    end
  end
end

class Instruction
  attr_reader :state

  def initialize(state)
    @state = state
    @branches = {}
  end

  def add_step(current_value, step)
    @branches[current_value] = [] if @branches[current_value].nil?
    @branches[current_value] << step
  end

  def print_instruction
    puts "In state #{@state}"
    @branches.keys.sort.each do |key|
      branch = @branches[key]

      puts "  If the current value is #{key}:"

      branch.each do |step|
        step.print_step
      end
    end
  end

  def steps_for_value(value)
    @branches[value]
  end
end

class Node
  attr_accessor :left, :right
  attr_accessor :value

  def initialize(value)
    @value = value
  end
end

class TuringMachine
  attr_reader :state

  def initialize(initial_state)
    @head = Node.new 0
    @state = initial_state
    @instructions = {}
  end

  def add_instruction(instruction)
    @instructions[instruction.state] = instruction
  end

  def checksum
    current = left_most
    value = 0

    until current.nil?
      value += current.value
      current = current.right
    end

    value
  end

  def left_most
    current = @head

    until current.left.nil?
      current = current.left
    end

    current
  end

  def print_blueprint
    @instructions.keys.sort.each do |key|
      @instructions[key].print_instruction
    end
  end

  def print_state
    print "#{@state}: ... "

    current = left_most
    until current.nil?
      if current == @head
        print "[#{current.value}]"
      else
        print " #{current.value} "
      end

      current = current.right
    end

    puts " ..."
  end

  def run
    current_value = @head.value
    instruction = @instructions[@state]
    steps = instruction.steps_for_value current_value

    steps.each do |step|
      case step.type
      when :write
        @head.value = step.op
      when :move
        if step.op == :left
          if @head.left.nil?
            node = Node.new 0

            node.right = @head
            @head.left = node

            @head = node
          else
            @head = @head.left
          end
        elsif step.op == :right
          if @head.right.nil?
            node = Node.new 0

            node.left = @head
            @head.right = node

            @head = node
          else
            @head = @head.right
          end
        else
          raise "Cannot move in direction #{@step.op}"
        end
      when :continue
        @state = step.op
      else
        raise "Unhandled step type: #{step.type}"
      end
    end
  end
end

turing_machine = nil
steps = 0
current_instruction = nil
current_value = nil

ARGF.each_line do |line|
  next if line.chomp.empty?

  if /Begin in state (.+)\./ =~ line
    turing_machine = TuringMachine.new $1.to_sym
  elsif /Perform a diagnostic checksum after (\d+) steps./ =~ line
    steps = $1.to_i
  elsif /In state (.+):/ =~ line
    unless current_instruction.nil?
      turing_machine.add_instruction current_instruction
      current_instruction = nil
    end

    current_instruction = Instruction.new $1.to_sym
    current_value = nil
  elsif /If the current value is (\d+):/ =~ line
    current_value = $1.to_i
  elsif /- Write the value (\d+)./ =~ line
    step = Step.new :write, $1.to_i
    current_instruction.add_step current_value, step
  elsif /- Move one slot to the (.+)\./ =~ line
    step = Step.new :move, $1.to_sym
    current_instruction.add_step current_value, step
  elsif /- Continue with state (.+)\./ =~ line
    step = Step.new :continue, $1.to_sym
    current_instruction.add_step current_value, step
  else
    raise "Unhandled line: #{line.chomp}"
  end
end

unless current_instruction.nil?
  turing_machine.add_instruction current_instruction
end

puts "Will start turing machine in state #{turing_machine.state} and run for #{steps} steps"
puts

turing_machine.print_blueprint
puts

steps.times do
  # turing_machine.print_state
  turing_machine.run
end

turing_machine.print_state

puts "Checksum: #{turing_machine.checksum}"