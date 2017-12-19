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
    def initialize(instructions)
        @instructions = instructions.dup

        reset!
    end

    def get(register)
        if register.is_a? Integer
            register
        else
            @registers[register] || 0
        end
    end

    def set(register, value)
        @registers[register] = value
    end

    def run
        received_value = nil

        while @head < @instructions.count
            print_program

            instruction = @instructions[@head]
            type = instruction.type
            op1 = instruction.op1
            op2 = instruction.op2

            case type
            when :snd
                @last_played_sound = get(op1)
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
                value = get(op1)
                if value != 0
                    received_value = @last_played_sound
                    break
                end

                @head += 1
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

        received_value
    end

    def print_program
        register_values = ('a'..'z').map { |v| " | #{v}: #{get v.to_sym}" }
        register_values.unshift " | X: #{@last_played_sound}"

        program_lines = @instructions.map { |i| i.inspect }
        max_lines = [register_values.count, program_lines.count].max

        puts "#{'-' * (15 + 15 + 1)}"

        max_lines.times do |i|
            program = program_lines[i] || ''
            register = register_values[i] || ''
            marker = (i == @head) ? '> ' : '  '

            puts "#{marker} #{program.ljust(15, ' ')} #{register.ljust(15, ' ')}"
        end
    end

    private

    def reset!
        @head = 0
        @registers = {}
        @last_played_sound = 0
    end
end

instructions = ARGF.each_line.map do |line|
    if /([a-z]+) (-?\S+)\s*(-?\S+)?/ =~ line
        Instruction.new $1.to_sym, $2, $3
    else
        raise "Unknown instruction: #{line.chomp}"
    end
end

instructions.each do |instruction|
    puts instruction.inspect
end

program = Program.new(instructions)
received_value = program.run

puts "Received: #{received_value}"