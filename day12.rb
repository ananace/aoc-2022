#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 12

Point = Struct.new :x, :y, :distance, :previous do
  def full_path
    return [self] unless previous

    previous.full_path + [self]
  end

  def +(other)
    Point.new(x + other.x, y + other.y)
  end

  def -(other)
    Point.new(x - other.x, y - other.y)
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def to_s
    "[#{x},#{y}]"
  end
end

class NoPathError < StandardError; end

class Implementation
  def initialize
    @map = []
    @size = Point.new 0, 0
  end

  def input(line)
    @map += line
    @size.x = line.size
    @size.y += 1
  end

  def output
    p_start = Point.new 0, 0
    p_end = Point.new 0, 0

    p_start_i = @map.index('S')
    p_start.y = p_start_i / @size.x
    p_start.x = p_start_i % @size.x
    p_end_i = @map.index('E')
    p_end.y = p_end_i / @size.x
    p_end.x = p_end_i % @size.x

    puts "Finding path from #{p_start} to #{p_end}..."

    path = find_path(p_start, p_end)

    puts "Part 1: #{path.full_path.size - 1}"

    #show(hilight: path.full_path)
    
    shortest = 2**32
    to_search = []
    @map.each.with_index do |v, i|
      next unless v == 'a'

      to_search << i
    end

    puts "Checking #{to_search.size} paths for shortest..."

    to_search.each do |i|
      p_start.y = i / @size.x
      p_start.x = i % @size.x

      # puts "Finding path from #{p_start} to #{p_end}..."

      path = find_path(p_start, p_end)
      # show(hilight: path.full_path)

      shortest = path.full_path.size - 1 if path.full_path.size - 1 < shortest
    rescue NoPathError # Unable to reach goal from this point
    end

    puts "Part 2: #{shortest}"
  end

  def show(hilight: nil)
    @size.y.times do |y|
      @size.x.times do |x|
        c = nil
        if hilight && hilight.any? { |h| h.x == x && h.y == y }
          c = "\e[1;32m"
        end
        print c if c

        print get(x, y, translate: false)
        print "\e[0m" if c
      end
      puts
    end
  end

  private

  def get(x, y = nil, translate: true, numerize: true)
    if x.is_a? Point
      y = x.y
      x = x.x
    end

    char = @map[y * @size.x + x]
    if translate
      char = 'a' if char == 'S'
      char = 'z' if char == 'E'
      return char.ord - 'a'.ord if numerize
    end
    char
  end

  def find_path(p_start, p_end)
    visited = Array.new(@size.x * @size.y, false)
    to_visit = []
    to_visit << p_start.dup
    to_visit.first.distance = 0

    until to_visit.empty?
      cur = to_visit.shift
      return cur if cur == p_end

      find_adjacent(cur).each do |adj|
        next if visited[adj.x + @size.x * adj.y]

        visited[adj.x + @size.x * adj.y] = true
        to_visit << adj
      end
    end

    raise NoPathError, 'Failed to find path'
  end

  def find_adjacent(point)
    adjacent = []
    c_v = get(point)

    [Point.new(0, -1), Point.new(1, 0), Point.new(0, 1), Point.new(-1, 0)].each do |p|
      p2 = point + p
      next if p2.x < 0 || p2.x > @size.x - 1 || p2.y < 0 || p2.y > @size.y - 1
      #next if point.full_path.include? p2

      v = get(p2)
      next if (v - c_v) > 1

      p2.previous = point
      p2.distance = point.distance + 1
      adjacent << p2
    end

    # puts "Adjacent to #{point.inspect}: #{adjacent.inspect}"
    adjacent
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
  impl.input line.strip.chars
end

impl.output
