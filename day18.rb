#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'
require 'set'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 18

Cube = Struct.new :x, :y, :z do
  def +(o)
    o = Cube.new(o,o,o) unless o.is_a? Cube
    Cube.new(x + o.x, y + o.y, z + o.z)
  end
  def -(o)
    o = Cube.new(o,o,o) unless o.is_a? Cube
    Cube.new(x - o.x, y - o.y, z - o.z)
  end

  def to_s
    "[#{x},#{y},#{z}]"
  end
end

AABB = Struct.new :min, :max do
  def size
    max - min
  end

  def include?(point)
    min.x <= point.x && point.x <= max.x &&
      min.y <= point.y && point.y <= max.y &&
      min.z <= point.z && point.z <= max.z
  end
end

class Implementation
  def initialize
    @cubes = []
  end

  def input(x, y, z)
    @cubes << Cube.new(x, y, z)
  end

  def output
    puts "Drop of size #{size.size} containing #{@cubes.size} cubes"

    sides = 0
    ((size.min.x)..(size.max.x)).each do |x|
      ((size.min.y)..(size.max.y)).each do |y|
        ((size.min.z)..(size.max.z)).each do |z|
          p = Cube.new(x,y,z)
          next unless has?(p)

          sides += 1 if !has?(p - Cube.new(1,0,0))
          sides += 1 if !has?(p - Cube.new(0,1,0))
          sides += 1 if !has?(p - Cube.new(0,0,1))
          sides += 1 if !has?(p - Cube.new(-1,0,0))
          sides += 1 if !has?(p - Cube.new(0,-1,0))
          sides += 1 if !has?(p - Cube.new(0,0,-1))
        end
      end
    end

    puts "Part 1: #{sides}"

    sides = 0
    exterior = flood_fill
    # puts "External shell: #{exterior}"
    exterior.each do |test|
      # puts "test: #{test}"
      sides += 1 if has?(test - Cube.new(1,0,0))
      sides += 1 if has?(test - Cube.new(0,1,0))
      sides += 1 if has?(test - Cube.new(0,0,1))
      sides += 1 if has?(test - Cube.new(-1,0,0))
      sides += 1 if has?(test - Cube.new(0,-1,0))
      sides += 1 if has?(test - Cube.new(0,0,-1))
    end

    puts "Part 2: #{sides}"
  end

  def flood_fill
    air = Set.new
    to_check = []

    limit = size.dup
    limit.min -= 1
    limit.max += 1

    to_check << limit.min
    air << to_check.first

    until to_check.empty?
      cur = to_check.shift
      
      (-1..1).each do |x|
        (-1..1).each do |y|
          (-1..1).each do |z|
            next if [x, y, z].map(&:zero?).count(true) < 2 || [x,y,z].all?(&:zero?)

            new = cur + Cube.new(x, y, z)
            next unless limit.include? new
            next if air.include? new
            next if has? new

            air << new
            to_check << new
          end
        end
      end
    end

    air
  end

  def show
    ((size.min.z)..(size.max.z)).each do |z|
      ((size.min.y)..(size.max.y)).each do |y|
        ((size.min.x)..(size.max.x)).each do |x|
          p = Cube.new(x,y,z)
          a = has?(p)

          if a
            print '#'
          else
            print '.'
          end
        end
        puts
      end
      puts
      puts
    end
  end

  def size
    @size ||= begin
      min = Cube.new(2**32,2**32,2**32)
      max = Cube.new(0,0,0)

      @cubes.each do |c|
        min.x = c.x if c.x < min.x
        min.y = c.y if c.y < min.y
        min.z = c.z if c.z < min.z

        max.x = c.x if c.x > max.x
        max.y = c.y if c.y > max.y
        max.z = c.z if c.z > max.z
      end

      AABB.new min, max
    end
  end

  def has?(pos)
    @cubes.include? pos
  end
end

impl = Implementation.new

#
# Boilerplate input handling
#

require 'optparse'

OptionParser.new do |parser|
  parser.banner = "Usage: #{$0} [args...]"

  parser.on '-s', '--sample', 'Use sample data even if real data is available' do
    $args.sample = true
  end

  parser.on '-h', '--help', 'Shows this help' do
    puts parser
    exit
  end
end.parse!

input = format('day%<day>02i.inp', day: DAY)
input = if File.exist?("#{input}.real") && !$args.sample
          "#{input}.real"
        elsif File.exist? "#{input}.sample"
          "#{input}.sample"
        else
          input
        end

#
# Actual input/output action
#

open(input).each_line do |line|
  impl.input *line.strip.split(',').map(&:to_i)
end

#impl.show

impl.output
