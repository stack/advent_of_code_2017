#!/usr/bin/env ruby

class Bridge
  attr_reader :highest_bridge
  attr_reader :highest_strength
  attr_reader :longest_bridge
  attr_reader :longest_strength

  def initialize(components)
    @components = components
    @needs = 0
    @highest_strength = 0
    @highest_bridge = []
    @longest_strength = 0
    @longest_bridge = []
  end

  def build!(components, bridge = [], needs = 0)
    # puts "Considering #{components.inspect} -- #{bridge.inspect} @ #{needs}"

    # A non-empty bridge is valid, so consider it
    unless bridge.empty?
      strength = bridge.reduce(0) { |acc, value| acc + value.lhs + value.rhs }
      output = bridge.map { |b| "#{b.lhs}/#{b.rhs}" }.join('--')

      # puts "#{output} = #{strength}"

      if strength > @highest_strength
        @highest_strength = strength
        @highest_bridge = bridge.dup
      end

      if bridge.count > @longest_bridge.count || (bridge.count == @longest_bridge.count && strength > @longest_strength)
        @longest_strength = strength
        @longest_bridge = bridge.dup
      end
    end

    # Find all available next components
    (next_components, remaining_components) = components.partition { |c| c.lhs == needs || c.rhs == needs }
    next_components.each do |component|
      available_components = remaining_components + (next_components - [component])
      next_bridge = bridge.dup
      next_bridge << component
      next_needs = component.lhs == needs ? component.rhs : component.lhs

      build!(available_components, next_bridge, next_needs)
    end
  end
end

class Component
  attr_reader :lhs
  attr_reader :rhs

  def initialize(lhs, rhs)
    @lhs = lhs
    @rhs = rhs
  end

  def self.parse(line)
    (lhs, rhs) = line.chomp.split('/')
    Component.new lhs.to_i, rhs.to_i
  end

  def inspect
    to_s
  end

  def to_s
    "#{@lhs}/#{@rhs}"
  end
end

components = ARGF.each_line.map do |line|
  Component.parse line
end

bridge = Bridge.new components
bridge.build! components

puts "Highest: #{bridge.highest_strength} = #{bridge.highest_bridge.inspect}"
puts "Longest: #{bridge.longest_strength} = #{bridge.longest_bridge.inspect}"