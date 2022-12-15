#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'
require 'set'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 15

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

  def manhattan_distance
    x.abs + y.abs
  end

  def to_s
    "[#{x},#{y}]"
  end
end

Rect = Struct.new :tl, :br do
  def size
    Point.new br.x - tl.x, br.y - tl.y
  end
end

class Sensor < Point
  attr_accessor :range

  def in_range?(p)
    (p - self).manhattan_distance <= range
  end
end

class Implementation
  def initialize
    @sensors = []
    @links = []
    @beacons = Set.new
  end

  def input(sensor, beacon)
    sensor = Sensor.new(sensor.x, sensor.y)

    @sensors << sensor
    @beacons << beacon
    @links << [sensor, beacon]

    sensor.range = (beacon - sensor).manhattan_distance
  end

  def output
    puts "Checking world of size #{size.size} with #{@sensors.count} sensors and #{@beacons.count} beacons..."

    tl = size.tl
    br = size.br

    if $args.sample
      to_check = 10
    else
      to_check = 2000000
    end

    # Part 1
    potentials = @sensors.select { |s| s.in_range? Point.new(s.x, to_check) }
    beacons = @beacons.select { |b| b.y == to_check }

    range = [2**32, 0]
    potentials.each do |s|
      w = (s.range - (s.y - to_check).abs)
      range[0] = s.x - w if s.x - w < range.first
      range[1] = s.x + w if s.x + w > range.last
    end
    range = Range.new(range.first, range.last)

    puts "Part 1: #{range.size - beacons.size}"

    # Part 2
    r = Time.now
    found = nil

    print "Scanning for Part 2... (000%)"

    last = []
    (0..(to_check * 2)).each do |i|
      # Scan from middle out, to optimize for the majority case
      # (only the first quarter of the input data is closer to the top than the middle)
      y = to_check + (i % 2 == 0 ? i : -i)/2

      ranges = @sensors.map do |s|
        next unless s.in_range? Point.new(s.x, y)

        w = s.range - (s.y - y).abs
        (s.x - w)..(s.x + w)
      end.reject(&:nil?)
      next if last == ranges

      last = ranges

      # Scan through the collected ranges in both directions
      narrowing = [ranges.map(&:first).min, ranges.map(&:last).max]
      3.times do
        pre = narrowing.dup
        ranges.each do |r|
          narrowing[0] = r.last + 1 if r.include? narrowing.first
          narrowing[1] = r.first - 1 if r.include? narrowing.last

          break if narrowing.last < narrowing.first
        end
        break if narrowing.last < narrowing.first || (pre.first == narrowing.first && pre.last == narrowing.last)
      end

      if Time.now - r > 1
        r = Time.now
        print "\b" * 6 + "(#{'%03i' % ((i.to_f / (to_check * 2.0)) * 100).to_i}%)"
      end

      # If the scan overlaps, then there's no empty spaces on the line
      next if narrowing.last < narrowing.first

      narrowing = Range.new *narrowing
      narrowing.each do |x|
        p = Point.new(x, y)
        
        next if potentials.any? { |s| s.in_range? p }

        found = p
        break
      end
      break if found
    end
    puts

    raise "Failed to find result" unless found

    puts "Part 2: #{found.x * 4000000 + found.y}"
  end

  def size
    @size ||= begin
      tl = Point.new 0,0
      br = Point.new 0,0

      (@sensors + @beacons.to_a).each do |p|
        tl.x = p.x if p.x < tl.x
        tl.y = p.y if p.y < tl.y
        br.x = p.x if p.x > br.x
        br.y = p.y if p.y > br.y
      end
      largest_range = (@sensors.map(&:range).max) + 1

      tl.x -= largest_range
      tl.y -= largest_range
      br.x += largest_range
      br.y += largest_range

      Rect.new tl, br
    end
  end

  def show(range: false)
    tl = size.tl
    br = size.br

    ((tl.y)..(br.y)).each do |y|
     ((tl.x)..(br.x)).each do |x|
        p = Point.new(x, y)
        if @sensors.include? p
          print 'S'
        elsif @beacons.include? p
          print 'B'
        elsif (range || y == 10) && @sensors.any? { |s| s.in_range? p }
          print '#'
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
  s, b = line.split(':').map { |l| Point.new *l.scan(/x=(-?\d+), y=(-?\d+)/).flatten.map(&:to_i) }
  impl.input s, b
end

impl.show range: true if $args.sample

impl.output
