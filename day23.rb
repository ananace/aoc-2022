#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'
require 'set'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 23

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

class Implementation
  def initialize
    @elves = []
    @line = 0
  end

  def input(line)
    line.each_char.with_index do |c, i|
      @elves << Vector.new(i, @line) if c == '#'
    end
    @line += 1
  end

  def output
    # puts "Input:"
    # show @elves
    elves = Marshal.load(Marshal.dump(@elves))
    blockmap = build_blockmap elves

    stopped = nil
    directions = %i[N S W E]
    10.times do |i|
      stopped = i + 1 if run_step(elves, directions, blockmap) == 0 && stopped.nil?
      blockmap = build_blockmap elves
      directions.push directions.shift
    end

    min = Vector.new 2**32, 2**32
    max = Vector.new -(2**32), -(2**32)

    elves.each do |e|
      min.x = e.x if e.x < min.x
      min.y = e.y if e.y < min.y
      max.x = e.x if e.x > max.x
      max.y = e.y if e.y > max.y
    end

    empty = 0
    ((min.y)..(max.y)).each do |y|
      ((min.x)..(max.x)).each do |x|
        next if elves.any? { |e| e == Vector.new(x, y) }

        empty += 1
      end
    end

    puts "Part 1: #{empty}"
    
    puts "Calculating part 2, this will take a while..."

    i = 10
    until stopped
      stopped = i + 1 if run_step(elves, directions, blockmap) == 0 && stopped.nil?
      blockmap = build_blockmap elves
      directions.push directions.shift
      i += 1
    end
    puts "Part 2: #{stopped}"
  end

  def run_step(elves, directions, blockmap)
    # puts "Elves: #{elves.inspect}, directions: #{directions.inspect}, blockmap: #{blockmap.inspect}"
    proposed = {}

    elves.each do |elf|
      # puts "For elf at #{elf}"
      
      blocked = Set.new
      (-1..1).each do |y|
        (-1..1).each do |x|
          next if x == 0 && y == 0

          new = elf + Vector.new(x, y)
          onmap = new + blockmap[:offset]
          # puts "Testing #{new} (#{onmap})"
          next if onmap.x < 0 || onmap.y < 0 || onmap.x >= blockmap[:size].x || onmap.y >= blockmap[:size].y

          found = blockmap[:map][onmap.x + blockmap[:size].x * onmap.y]

          blocked << :N if y < 0 && found
          blocked << :E if x > 0 && found
          blocked << :S if y > 0 && found
          blocked << :W if x < 0 && found
        end
      end

      # if blocked.empty?
      #   puts "- Feels satisfied"
      # elsif blocked.size == 4
      #   puts "- Is fully blocked"
      # else
      #   puts "- Blocked: #{blocked}"
      # end

      next if blocked.empty? || blocked.size == 4

      directions.each do |dir|
        next if blocked.include? dir

        # puts "- Proposes moving #{dir}"
        case dir
        when :N
          proposed[elf] = elf + Vector.new(0, -1)
        when :E
          proposed[elf] = elf + Vector.new(1, 0)
        when :S
          proposed[elf] = elf + Vector.new(0, 1)
        when :W
          proposed[elf] = elf + Vector.new(-1, 0)
        end
        break
      end
    end

    moved = 0
    elves.each do |elf|
      next unless proposed.key? elf

      proposal = proposed.delete elf
      # puts "Elf #{elf} proposes #{proposal}"

      size = proposed.size
      proposed.delete_if { |_, dest| dest == proposal }

      if proposed.size < size
        # puts "But other elf has same proposal"
        next
      end

      elf.x = proposal.x
      elf.y = proposal.y
      moved += 1
    end

    # puts
    # puts "After step: (#{moved} moved)"
    # show elves
    moved
  end

  def build_blockmap(points)
    min = Vector.new 2**32, 2**32
    max = Vector.new -(2**32), -(2**32)

    points.each do |e|
      min.x = e.x if e.x < min.x
      min.y = e.y if e.y < min.y
      max.x = e.x if e.x > max.x
      max.y = e.y if e.y > max.y
    end

    map = {
      size: Vector.new(max.x - min.x + 1, max.y - min.y + 1),
      offset: Vector.new(-min.x, -min.y)
    }
    map[:map] = Array.new(map[:size].x * map[:size].y)

    ((min.y)..(max.y)).each do |y|
      ((min.x)..(max.x)).each do |x|
        at = Vector.new x, y
        onmap = at + map[:offset]

        map[:map][onmap.x + map[:size].x * onmap.y] = true if points.any? { |p| p == at }
      end
    end
    # show points
    # puts "Blockmap: #{map}"

    map
  end
  def show(points)
    min = Vector.new 2**32, 2**32
    max = Vector.new -(2**32), -(2**32)

    points.each do |e|
      min.x = e.x if e.x < min.x
      min.y = e.y if e.y < min.y
      max.x = e.x if e.x > max.x
      max.y = e.y if e.y > max.y
    end

    ((min.y)..(max.y)).each do |y|
      ((min.x)..(max.x)).each do |x|
        at = Vector.new x, y
        
        if points.any? { |p| p == at }
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
  parser.on '-S', '--sample2', 'Use sample2 data even if real data is available' do
    $args.sample2 = true
  end

  parser.on '-h', '--help', 'Shows this help' do
    puts parser
    exit
  end
end.parse!

input = format('day%<day>02i.inp', day: DAY)
input = if File.exist?("#{input}.real") && !$args.sample && !$args.sample2
          "#{input}.real"
        elsif File.exist?("#{input}.sample") && !$args.sample2
          "#{input}.sample"
        elsif File.exist? "#{input}.sample2"
          "#{input}.sample2"
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
