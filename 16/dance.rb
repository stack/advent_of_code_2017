#!/usr/bin/env ruby

require 'optparse'

class DanceFloor
    attr_reader :dancers

    def initialize(dancers)
        @dancers = ('a'..'z').to_a[0, dancers]
    end

    def exchange(lhs, rhs)
        temp = @dancers[lhs]
        @dancers[lhs] = @dancers[rhs]
        @dancers[rhs] = temp
    end

    def partner(lhs, rhs)
        lhs_index = @dancers.index lhs
        rhs_index = @dancers.index rhs

        exchange lhs_index, rhs_index
    end

    def print_dancers
        puts @dancers.join ' '
    end

    def spin(amount)
        @dancers.rotate!(amount * -1)
    end
end

class Step
    attr_reader :type
    attr_reader :lhs
    attr_reader :rhs

    def initialize(line)
        if /s(\d+)/ =~ line
            @type = :s
            @lhs = $1.to_i
            @rhs = nil
        elsif /^x(\d+)\/(\d+)/ =~ line
            @type = :x
            @lhs = $1.to_i
            @rhs = $2.to_i
        elsif /^p([a-z])\/([a-z])/ =~ line
            @type = :p
            @lhs = $1
            @rhs = $2
        else
            raise "Invalid step line: #{line}"
        end
    end
end

class Optimizer
    def initialize(dancers, instructions)
        @dancers = dancers
        @instructions = instructions

        reset!
    end

    def run(times)
        cycle = find_cycle
        reset!

        puts "There is a cycle of #{cycle}"

        @dance_floor.print_dancers

        cycle.times do
            run_once
            @dance_floor.print_dancers
        end

        cycle_times = times / cycle

        puts "Cycle times: #{cycle_times}"

        run_times = times % cycle

        puts "Run times: #{run_times}"
        
        run_times += cycle if cycle_times > 0

        puts "Total runs: #{run_times}"

        reset!
        run_times.times do
            run_once
        end

        @dance_floor.print_dancers
    end

    private

    def find_cycle
        times = 0
        visited = [@dance_floor.dancers.dup]

        loop do
            run_once
            times += 1

            if visited.include?(@dance_floor.dancers)
                break
            else
                visited << @dance_floor.dancers.dup
            end
        end

        times
    end

    def reset!
        @dance_floor = DanceFloor.new @dancers
    end

    def run_once
        @instructions.each do |step|
            case step.type
            when :s then @dance_floor.spin step.lhs
            when :x then @dance_floor.exchange step.lhs, step.rhs
            when :p then @dance_floor.partner step.lhs, step.rhs
            else
                raise "Invalid step: #{step}"
            end
        end
    end
end

options = { dancers: 16, times: 1 }
opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: #{$0} [OPTIONS]"
    opt.separator ""
    opt.separator "OPTIONS"

    opt.on('-d', '--dancers DANCERS', 'the number of dancers') do |d|
        options[:dancers] = d.to_i
    end

    opt.on('-t', '--times TIMES', 'the number of times to dance') do |t|
        options[:times] = t.to_i
    end
end
opt_parser.parse!

raise 'Invalid number of dancers' unless (options[:dancers] > 0 && options[:dancers] <= 26)

puts "Running with #{options[:dancers]} dancer(s), #{options[:times]} time(s)"

instructions = ARGF.read.split(',').map { |line| Step.new line }

optimizer = Optimizer.new options[:dancers], instructions
optimizer.run options[:times]
