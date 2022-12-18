#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 17

Vector = Struct.new :x, :y do
  def +(o)
    return Vector.new(x + o, y + o) unless o.is_a? Vector

    Vector.new(x + o.x, y + o.y)
  end
  def -(o)
    return Vector.new(x - o, y - o) unless o.is_a? Vector

    Vector.new(x - o.x, y - o.y)
  end
  def /(o)
    return Vector.new(x / o, y / o) unless o.is_a? Vector

    Vector.new(x / o.x, y / o.y)
  end

  def product
    x.abs * y.abs
  end
end
Rect = Struct.new :tl, :br do
  def size
    Vector.new br.x - tl.x, br.y - tl.y
  end

  def include?(point)
    tl.x <= point.x && point.x <= br.x &&
      tl.y <= point.y && point.y <= br.y
  end
end
Rock = Struct.new :position, :size, :pattern do
  def rect
    Rect.new position, position + (size - 1)
  end
  def include?(point)
    rect.include? point
  end
end

ROCKS = [
  Rock.new(nil, Vector.new(4, 1).freeze, '####').freeze,
  Rock.new(nil, Vector.new(3, 3).freeze, '.#.###.#.').freeze,
  Rock.new(nil, Vector.new(3, 3).freeze, '..#..####').freeze,
  Rock.new(nil, Vector.new(1, 4).freeze, '####').freeze,
  Rock.new(nil, Vector.new(2, 2).freeze, '####').freeze
].freeze

class Implementation
  def initialize
    @jets = ''
  end

  def input(jets)
    @jets = jets
  end

  def output
    size = Vector.new(7, 1)
    world = Array.new(size.product)
    top_layer = 0

    puts "Dropping rocks..."
    # show world, size
    # puts

    d = Time.now

    rocks = 0
    rock_iter = 0
    jet_iter = 0
    until rocks == 2022
      rock = ROCKS[rock_iter % ROCKS.size].dup
      rock_iter += 1

      rock.position = Vector.new 2, size.y - top_layer - rock.size.y - 3
      
      req_height = top_layer + rock.size.y + 5
      req_height = 4 if req_height < 4
      if req_height > size.y
        diff = req_height - size.y
        size.y = req_height

        (diff * size.x).times do
          world.unshift nil
        end
      end

      #size.y += 3
      rock.position = Vector.new 2, size.y - top_layer - rock.size.y - 3

      # puts "Dropping at #{top_layer} (#{rock.position} in #{size})"
      # show rock.pattern, rock.size
      # puts

      # gets

      # show world, size, falling: rock
      # puts

      while true
        move = Vector.new(0, 0)
        move.x = @jets[jet_iter % @jets.size] == '>' ? 1 : -1
        jet_iter += 1

        # puts "Jet moving #{move}"

        new = rock.dup.tap do |new|
          new.position += move
        end

        rock = new unless colliding?(world, size, new)

        # show world, size, falling: rock
        # puts
        # puts "Dropping down"

        move.x = 0
        move.y = 1
        new = rock.dup.tap do |new|
          new.position += move
        end

        unless colliding?(world, size, new)
          rock = new 
        else
          (0..(rock.size.x-1)).each do |x|
            (0..(rock.size.y-1)).each do |y|
              next unless rock.pattern[x + rock.size.x * y] == '#'
              
              p = rock.position + Vector.new(x, y)
              world[p.x + size.x * p.y] = '#'
              top_layer = size.y - p.y if (size.y - p.y) > top_layer
            end
          end

          rock = nil
        end

        # show world, size, falling: rock
        # puts

        break unless rock
      end

      # show world, size
      # puts
      
      if Time.now - d > 1
        d = Time.now
        puts "Dropped #{rocks}, top: #{top_layer}"
      end

      rocks += 1
    end

    puts "Part 1: #{top_layer}"
  end

  def colliding?(world, size, rock)
    (0..(rock.size.x - 1)).each do |x|
      (0..(rock.size.y - 1)).each do |y|
        next unless rock.pattern[x + rock.size.x * y] == '#'
        
        p = rock.position + Vector.new(x, y)
        return true if p.x < 0 || p.x >= size.x || p.y >= size.y
        return true if world[p.x + size.x * p.y]
      end
    end
    false
  end

  def show(world, size, falling: nil)
    (0..size.y).each do |y|
      (-1..size.x).each do |x|
        at = '|' if x < 0 || x == size.x
        at = '-' if y == size.y
        at = '+' if (x < 0 || x == size.x) && y == size.y

        if falling && falling.include?(Vector.new(x, y))
          at ||= falling.pattern[(x - falling.position.x) + falling.size.x * (y - falling.position.y)]
          at.sub!('#', '@')
        end
        at ||= world[x + size.x * y]

        if at
          print at
        else
          print '.'
        end
      end
      puts
    end
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
  impl.input line.strip
end

impl.output
