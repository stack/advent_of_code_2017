#!/usr/bin/env ruby

class Instruction
    attr_reader :type
    attr_reader :op1
    attr_reader :op2

    def initialize(type, op1, op2)
        @type = type

        if /(-?\d+)/ =~ op1
            @op1 = $1.to_i
        elsif /([a-z])/ =~ op1
            @op1 = $1.to_sym
        else
            raise "Invalid op1: #{op1}"
        end

        unless op2.nil?
            if /(-?\d+)/ =~ op2
                @op2 = $1.to_i
            elsif /([a-z])/ =~ op2
                @op2 = $1.to_sym
            else
                raise "Invalid op2: #{op2}"
            end
        end
    end

    def inspect
        value = "#{@type} #{@op1}"
        value += " #{@op2}" unless @op2.nil?

        value
    end
end

class Program
    attr_reader :sends
    attr_accessor :other

    def initialize(instructions, id)
        @instructions = instructions.dup
        @id = id

        reset!
    end

    def done?
        @head >= @instructions.count
    end

    def get(register)
        if register.is_a? Integer
            register
        else
            @registers[register] || 0
        end
    end

    def queue(value)
        @inbound_queue << value
    end

    def set(register, value)
        @registers[register] = value
    end

    def stuck?
        @instructions[@head].type == :rcv && @inbound_queue.empty?
    end

    def step
        instruction = @instructions[@head]
        type = instruction.type
        op1 = instruction.op1
        op2 = instruction.op2

        case type
        when :snd
            value = get(op1)
            @other.queue value
            @sends += 1
            @head += 1
        when :set
            set(op1, get(op2))
            @head += 1
        when :add
            lhs = get(op1)
            rhs = get(op2)

            set(op1, lhs + rhs)

            @head += 1
        when :mul
            lhs = get(op1)
            rhs = get(op2)

            set(op1, lhs * rhs)

            @head += 1
        when :mod
            lhs = get(op1)
            rhs = get(op2)

            set(op1, lhs % rhs)

            @head += 1
        when :rcv
            value = @inbound_queue.shift

            unless value.nil?
                set(op1, value)
                @head += 1
            end
        when :jgz
            jump = get(op2)
            value = get(op1)

            if value > 0
                @head += jump
            else
                @head += 1
            end
        else
            raise "Unknown instruction type: #{type}"
        end
    end

    def print_program
        register_values = ('a'..'z').map { |v| " | #{v}: #{get v.to_sym}" }
        register_values.unshift " | Q: #{@inbound_queue.inspect}"

        program_lines = @instructions.map { |i| i.inspect }
        max_lines = [register_values.count, program_lines.count].max

        max_lines.times.map do |i|
            program = program_lines[i] || ''
            register = register_values[i] || ''
            marker = (i == @head) ? '> ' : '  '

            "#{marker} #{program.ljust(17, ' ')} #{register.ljust(17, ' ')}"
        end
    end

    private

    def reset!
        @head = 0
        @registers = { p: @id }
        @inbound_queue = []
        @sends = 0
    end
end

instructions = ARGF.each_line.map do |line|
    if /([a-z]+) (-?\S+)\s*(-?\S+)?/ =~ line
        Instruction.new $1.to_sym, $2, $3
    else
        raise "Unknown instruction: #{line.chomp}"
    end
end

program0 = Program.new(instructions, 0)
program1 = Program.new(instructions, 1)

program0.other = program1
program1.other = program0

until program0.done? || program1.done?
    puts "#{'-' * 78}"

    lines0 = program0.print_program
    lines1 = program1.print_program

    lines0.count.times do |idx|
        puts "#{lines0[idx]} ||| #{lines1[idx]}"
    end

    program0.step
    program1.step

    if program0.stuck? && program1.stuck?
        puts "DEADLOCK!"
        break
    end
end

puts "Sends: #{program0.sends} , #{program1.sends}"