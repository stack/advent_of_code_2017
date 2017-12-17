#!/usr/bin/env ruby

require 'optparse'

class Node
    attr_accessor :prev
    attr_accessor :next
    attr_reader :value

    def initialize(value)
        @value = value
    end
end

class SpinLock
    def initialize(steps, iterations)
        @steps = steps
        @iterations = iterations

        reset!
    end

    def next_value
        @head.next.value
    end

    def run
        reset!

        while @current_step < @iterations
            @steps.times do
                @head = @head.next
            end

            next_head = Node.new @current_step + 1
            next_head.prev = @head
            next_head.next = @head.next

            @head.next = next_head
            next_head.next.prev = next_head

            @head = next_head
            @data_size += 1

            # print_spin_lock

            @current_step += 1
        end
    end

    private

    def print_spin_lock

        current = @data
        @data_size.times do
            if current == @head
                print "(#{current.value})"
            else
                print " #{current.value} "
            end

            current = current.next
        end

        puts
    end

    def reset!
        @current_step = 0

        @data = Node.new 0
        @data.prev = @data
        @data.next = @data

        @data_size = 1

        @head = @data
    end
end

class SpinLock2
    def initialize(steps, iterations)
        @steps = steps
        @iterations = iterations

        reset!
    end

    def run
        position_1 = nil

        @iterations.times do |i|
            index = (@head + @steps) % @data_size
            @head = index + 1

            position_1 = i + 1 if @head == 1

            @data_size += 1
        end

        position_1
    end

    private 

    def reset!
        @head = 0
        @data_size = 1
    end
end

options = {
    steps: 366,
    iterations: 2017
}

opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: #{$0} [OPTIONS]"
    opt.separator ''
    opt.separator 'OPTIONS'

    opt.on('-h', '--help', 'print this help message') do
        puts opt
        exit
    end

    opt.on('-i', '--iterations ITERATIONS', 'the number of iterations to perform') do |i|
        options[:iterations] = i.to_i
    end

    opt.on('-s', '--steps STEPS', 'the number of steps to take each iteration') do |s|
        options[:steps] = s.to_i
    end
end

opt_parser.parse!
puts "Using #{options[:steps]} steps and #{options[:iterations]} iterations"

spin_lock = SpinLock.new options[:steps], options[:iterations]
spin_lock.run

puts "Next value: #{spin_lock.next_value}"

spin_lock_2 = SpinLock2.new options[:steps], 50_000_000
position_1 = spin_lock_2.run

puts "Position 1: #{position_1}"