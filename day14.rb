#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 14

class OutOfWorldError < StandardError; end

class Integer
  def sign
    self < 0 ? -1 : (self > 0 ? 1 : 0)
  end
end
Point = Struct.new :x, :y do
  def -(other)
    other = Point.new other, other unless other.is_a? Point
    Point.new(x - other.x, y - other.y)
  end
  def +(other)
    other = Point.new other, other unless other.is_a? Point
    Point.new(x + other.x, y + other.y)
  end
  def ==(other)
    x == other.x && y == other.y
  end
  def abs
    Point.new(x.abs, y.abs)
  end
  def sign
    Point.new(x.sign, y.sign)
  end

  def product
    x * y
  end

  def to_s
    "[#{x},#{y}]"
  end
end
Rect = Struct.new :tl, :br do
  def size
    (br - tl).abs + 1
  end
  def include? point
    tl.x <= point.x && tl.y <= point.y && br.x >= point.x && br.y >= point.y
  end

  def to_s
    "{#{tl}->#{br}}"
  end
end

class Implementation
  def initialize
    @lines = []
    @world = Rect.new(Point.new(500, 0), Point.new(0, 0))
  end

  def add_line(line)
    segments = line.map { |seg| Point.new *seg.split(',').map(&:to_i) }
    segments.each do |seg|
      @world.tl.x = seg.x if seg.x < @world.tl.x
      @world.tl.y = seg.y if seg.y < @world.tl.y
      @world.br.x = seg.x if seg.x > @world.br.x
      @world.br.y = seg.y if seg.y > @world.br.y
    end

    @lines << segments
  end

  def output
    puts "Calculating based on world between #{@world} (#{@world.size})"

    map = Array.new(@world.size.product)

    tl = @world.tl
    set(500, 0, '+', map, tl: tl)
    add_lines(map, @lines, tl)

    show map

    step = drop_sand map, @world

    puts "Escaping world at step #{step}"
    show map

    puts "Part 1: #{step - 1}"

    # XXX Should probably calculate the new size in a more appropriate manner
    world = @world.dup
    world.tl.x -= 200
    world.br.x += 150
    world.br.y += 2

    map = Array.new(world.size.product)
    tl = world.tl

    set(500, 0, '+', map, tl: tl)
    ((world.tl.x)..(world.br.x)).each do |x|
      set(x, world.br.y, '#', map, tl: tl)
    end
    add_lines(map, @lines, tl)
    show map

    step = drop_sand map, world

    puts "Reaching top at step #{step}"
    show map

    puts "Part 2: #{step}"
  end

  def show(map)
    s = @world.size
    s.product.times do |i|
      print (map[i] || '.')
      puts if (i + 1) % s.x == 0
    end
  end

  def add_lines(map, lines, tl)
    lines.each do |line|
      point = nil
      line.each do |segment|
        if point
          # puts "Drawing line between #{point}, #{segment}"
          set(point.x, point.y, '#', map, tl: tl)

          dir = (segment - point).sign
          until point == segment
            # puts "At #{point}"
            point += dir
            set(point.x, point.y, '#', map, tl: tl)
          end
        end
        point = segment
      end
    end
  end

  def drop_sand(map, world)
    tl = world.tl
    step = 0
    while true do
      sand = Point.new(500, 0)
      step = step + 1 
      rest = false

      while true
        np = sand + Point.new(0, 1)
        break unless world.include?(np) 
        v = get(np.x, np.y, map, tl: tl) 
        # puts "At #{np} (#{v})"
        if v
          t = np + Point.new(-1, 0)
          break unless world.include?(t) 
          # puts "Checking #{t}"
          if get(t.x, t.y, map, tl: tl)
            t.x += 2
            break unless world.include?(t) 
            # puts "Checking #{t}"
            if get(t.x, t.y, map, tl: tl)
              set(sand.x, sand.y, 'o', map, tl: tl)
              rest = true
              break
            else
              np = t
            end
          else
            np = t
          end
        end
        sand = np
      end

      break if sand == Point.new(500, 0)
      break unless rest
    end

    step
  end

  def get(x, y, map, tl: nil)
    rx = x
    ry = y

    if tl
      rx = rx - tl.x
      ry = ry - tl.y
    end

    s = @world.size
    raise OutOfWorldError, "#{x},#{y}: Invalid position" if rx < 0 || ry < 0 || rx > s.x - 1 || ry > s.y - 1

    map[rx + s.x * ry]
  end

  def set(x, y, v, map, tl: nil)
    rx = x
    ry = y

    if tl
      rx = rx - tl.x
      ry = ry - tl.y
    end

    s = @world.size
    raise OutOfWorldError, "#{x},#{y}: Invalid position" if rx < 0 || ry < 0 || rx > s.x - 1 || ry > s.y - 1

    map[rx + s.x * ry] = v
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
  impl.add_line line.strip.split(' -> ')
end

impl.output
