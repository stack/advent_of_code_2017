#!/usr/bin/env ruby

class Particle
  attr_reader :id

  attr_accessor :x_position
  attr_accessor :y_position
  attr_accessor :z_position

  attr_accessor :x_acceleration
  attr_accessor :y_acceleration
  attr_accessor :z_acceleration

  attr_accessor :x_velocity
  attr_accessor :y_velocity
  attr_accessor :z_velocity

  def initialize(id)
    @id = id
  end

  def self.parse(id, line)
    particle = Particle.new id

    if /p=<(.+),(.+),(.+)>, v=<(.+),(.+),(.+)>, a=<(.+),(.+),(.+)>/ =~ line
      particle.x_position = $1.to_i
      particle.y_position = $2.to_i
      particle.z_position = $3.to_i
      particle.x_velocity = $4.to_i
      particle.y_velocity = $5.to_i
      particle.z_velocity = $6.to_i
      particle.x_acceleration = $7.to_i
      particle.y_acceleration = $8.to_i
      particle.z_acceleration = $9.to_i
    else
      raise "Cannot parse particle line: #{line.chomp}"
    end

    particle
  end

  def distance
    @x_position.abs + @y_position.abs + @z_position.abs
  end

  def step!
    @x_velocity += @x_acceleration
    @y_velocity += @y_acceleration
    @z_velocity += @z_acceleration

    @x_position += @x_velocity
    @y_position += @y_velocity
    @z_position += @z_velocity
  end
end

class GPU
  attr_reader :particles

  def initialize
    @particles = []
  end

  def add_particle(particle)
    @particles << particle
  end

  def print_particles
    @particles.each do |p|
      puts "#{p.id.to_s.ljust(3, ' ')}: #{p.distance.to_s.rjust(5, ' ')}, p=<#{p.x_position},#{p.y_position},#{p.z_position}>, v=<#{p.x_velocity},#{p.y_velocity},#{p.z_velocity}>, a=<#{p.x_acceleration},#{p.y_acceleration},#{p.z_acceleration}>"
    end
  end

  def step!
    @particles.each { |p| p.step! }
    @particles.sort! { |lhs, rhs| lhs.distance <=> rhs.distance }
  end

  def remove_collisions!
    particle_map = {}

    @particles.each do |p|
      key = "#{p.x_position},#{p.y_position},#{p.z_position}"
      
      if particle_map.key? key
        particle_map[key] << p.id
      else
        particle_map[key] = [p.id]
      end
    end

    ids_to_remove = []
    particle_map.each do |key, value|
      ids_to_remove += value if value.count > 1
    end

    ids_to_remove.each do |id|
      idx = @particles.find_index { |x| x.id == id }
      @particles.delete_at idx
    end
  end
end

gpu = GPU.new

ARGF.each_line.each_with_index do |line, idx|
  particle = Particle.parse idx, line
  gpu.add_particle particle
end

gpu.print_particles
puts

1000.times do
  gpu.step!
  gpu.remove_collisions!
  gpu.print_particles
  puts "Particles remaining: #{gpu.particles.count}"
end