#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 24

Vector = Struct.new :x, :y do
  def +(o)
    o = Vector.new o, o unless o.is_a? Vector
    Vector.new x + o.x, y + o.y
  end
  def -(o)
    o = Vector.new o, o unless o.is_a? Vector
    Vector.new x - o.x, y - o.y
  end
  def to_s
    "[#{x},#{y}]"
  end
end

Blizzard = Struct.new :position, :direction do
  def movement
    case direction
    when :up
      Vector.new 0, -1
    when :right
      Vector.new 1, 0
    when :down
      Vector.new 0, 1
    when :left
      Vector.new -1, 0
    end
  end
end

DIRMAP = {
  '>' => :right,
  'v' => :down,
  '<' => :left,
  '^' => :up
}.freeze
CHARMAP = {
  right: '>',
  down: 'v',
  left: '<',
  up: '^'
}

class Implementation
  def initialize
    @blizzards = []
    @start = nil
    @end = nil
    @size = Vector.new 0, 0
  end

  def input(line, last = false)
    @start = Vector.new(line.index('.'), 0) unless @start
    @end = Vector.new(line.index('.'), @size.y) if last && !@end

    line.each_char.with_index do |c, i|
      next if c == '.' || c == '#'
      raise "Unknown char '#{c}'" unless DIRMAP.key? c

      @blizzards << Blizzard.new(Vector.new(i, @size.y), DIRMAP[c])
    end

    @size.x = line.size
    @size.y += 1
  end

  def output
    minutes = find_path(@start, @end)

    puts "Part 1: #{minutes + 1}"

    minutes = find_path(@end, @start, minutes)
    minutes = find_path(@start, @end, minutes)

    puts "Part 2: #{minutes + 1}"
  end

  def build_bitmap
    bitmap = Array.new @size.x * @size.y, '.'
    @size.x.times do |x|
      bitmap[x] = '#'
      bitmap[x + @size.x * (@size.y - 1)] = '#'
    end
    @size.y.times do |y|
      bitmap[@size.x * y] = '#'
      bitmap[@size.x - 1 + @size.x * y] = '#'
    end

    bitmap[@start.x + @size.x * @start.y] = '.'
    bitmap[@end.x + @size.x * @end.y] = '.'
    bitmap
  end

  def find_path(from, to, minutes = 0)
    reached = false
    bitmap = build_bitmap

    until reached
      minutes += 1

      # Inject new potentials based off of waiting at the start for every minute
      [-1, 1].each do |y|
        new_start = from + Vector.new(0, y)
        next if new_start.y <= 0 || new_start.y >= @size.y - 1

        bitmap[new_start.x + @size.x * new_start.y] = 'E'
      end

      @blizzards.each do |b|
        new = b.position + b.movement

        new.x = @size.x - 2 if new.x == 0
        new.x = 1 if new.x >= @size.x - 1
        new.y = @size.y - 2 if new.y == 0
        new.y = 1 if new.y >= @size.y - 1

        b.position = new

        bitmap[new.x + @size.x * new.y] = '.'
      end

      paths = []
      @size.x.times do |x|
        @size.y.times do |y|
          paths << Vector.new(x, y) if bitmap[x + @size.x * y] == 'E'
        end
      end

      paths.each do |point|
        (-1..1).each do |x|
          (-1..1).each do |y|
            next if x.abs > 0 && y.abs > 0 # Skip diagonals

            new = point + Vector.new(x, y)

            reached = new if new == to
            break if reached
            next if new.x < 1 || new.y < 1 || new.x >= @size.x - 1 || new.y >= @size.y - 1 # Don't exit the map

            bitmap[new.x + @size.x * new.y] = 'E'
          end
          break if reached
        end
        break if reached
      end
    end

    minutes
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

lines = open(input).lines.to_a
lines.each do |line|
  impl.input line.strip, line == lines.last
end

impl.output
