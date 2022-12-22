#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 22

Vector = Struct.new :x, :y do
  def +(o)
    o = Vector.new o, o unless o.is_a? Vector
    Vector.new x + o.x, y + o.y
  end
  def -(o)
    o = Vector.new o, o unless o.is_a? Vector
    Vector.new x - o.x, y - o.y
  end

  def angle
    Math.atan2 y, x
  end

  def rotate_right
    target = angle + Math::PI / 2
    Vector.new Math.cos(target).to_i, Math.sin(target).to_i
  end

  def rotate_left
    target = angle - Math::PI / 2
    Vector.new Math.cos(target).to_i, Math.sin(target).to_i
  end

  def to_char
    case self
    when Vector.new(1, 0)
      '>'
    when Vector.new(0, 1)
      'v'
    when Vector.new(-1, 0)
      '<'
    when Vector.new(0, -1)
      '^'
    end
  end

  def to_s
    "[#{x},#{y}]"
  end
end

class Implementation
  def initialize
    @map = []
    @size = Vector.new 0, 0

    @path = nil
  end

  def input_map(line)
    @map << line.chomp

    @size.x = line.size if line.size > @size.x
    @size.y += 1
  end

  def input_path(path)
    @path = path
  end

  def munge
    @map.map! do |line|
      line.ljust @size.x, ' '
    end
    @map = @map.join

    path = []
    buf = ''
    @path.each_char do |c|
      if c =~ /L|R/
        buf = buf.to_i if buf.to_i.to_s == buf
        path << buf
        path << c.to_sym

        buf = ''
      else
        buf += c
      end
    end
    buf = buf.to_i if buf.to_i.to_s == buf
    path << buf unless buf.is_a?(String) && buf.empty?

    @path = path
  end

  DIR_COST = {
    Vector.new(1, 0) => 0,
    Vector.new(0, 1) => 1,
    Vector.new(-1, 0) => 2,
    Vector.new(0, -1) => 3,
  }
  def output
    # puts inspect
    munge

    puts "Map:"
    show

    you = Vector.new 0, 0
    dir = Vector.new 1, 0
    at = ' '
    while at != '.'
      you.x += 1
      at = @map[you.x + you.y * @size.x]
    end

    puts "Starting at #{you}, moving #{dir}"
    # puts @path.inspect

    p = []
    @path.each do |step|
      case step
      when Integer
        step.times do
          new = you + dir
          new.x = 0 if new.x >= @size.x
          new.x = @size.x - 1 if new.x < 0
          new.y = 0 if new.y >= @size.y
          new.y = @size.y - 1 if new.y < 0

          at = @map[new.x + new.y * @size.x]
          next if at == '#'
 
          while at.nil? || at.strip.empty?
            new = new + dir
            new.x = 0 if new.x >= @size.x
            new.x = @size.x - 1 if new.x < 0
            new.y = 0 if new.y >= @size.y
            new.y = @size.y - 1 if new.y < 0

            at = @map[new.x + new.y * @size.x]
          end
          next if at == '#'

          you = new
          p << [you, dir]
        end
      when Symbol
        dir = dir.rotate_left if step == :L
        dir = dir.rotate_right if step == :R
      end

      # puts "After #{step}; #{you}, moving #{dir}"
    end

    # show path: p
    puts "Part 1: #{1000 * (you.y + 1) + 4 * (you.x + 1) + DIR_COST[dir]}"
  end

  def show(path: nil)
    @size.y.times do |y|
      @size.x.times do |x|
        at = path.find { |p, v| p == Vector.new(x, y) } if path
        if at
          print at.last.to_char
        else
          print @map[x + y * @size.x]
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

stage = :map
open(input).each_line do |line|
  case stage
  when :map
    if line.strip.empty?
      stage = :path
    else
      impl.input_map line
    end
  when :path
    impl.input_path line.strip
  end
end

impl.output
