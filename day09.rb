#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 9

class Numeric
  def sign
    self <=> 0
  end
end

Position = Struct.new :x, :y do
  def adjacent?(other)
    (other.x - x).abs <= 1 && (other.y - y).abs <= 1
  end

  def move(diff)
    self.x += diff.x
    self.y += diff.y
  end

  def -(other)
    Position.new x - other.x, y - other.y
  end
  def +(other)
    Position.new x + other.x, y + other.y
  end

  def sign
    Position.new x.sign, y.sign
  end

  def to_s
    "[#{x}, #{y}]"
  end
end

class Implementation
  def initialize
    @steps = []
  end

  def input(dir, len)
    diff = case dir
           when :u
             Position.new 0, -1
           when :r
             Position.new 1, 0
           when :d
             Position.new 0, 1
           when :l
             Position.new -1, 0
           end
    @steps << OpenStruct.new(
      dir: dir, 
      len: len,
      move: diff
    )
  end

  def output
    h_p = Position.new 0, 0
    s_visited = [h_p.dup]
    l_visited = [h_p.dup]

    knots = []
    9.times { knots << Position.new(0, 0) }

    puts 'Calculating...'
    # puts "Rope: #{h_p}, #{knots.join ', '}"
    @steps.each do |step|
      # puts "Moving #{step.len} #{step.dir}"

      step.len.times do
        h_p.move(step.move)

        knots.each.with_index do |knot, i|
          other = (i == 0 ? h_p : knots[i - 1])

          unless knot.adjacent?(other)
            diff = (other - knot).sign
            knot = (knots[i] += diff)
          end

          if i == 0
            s_visited << knot unless s_visited.include?(knot)
          elsif i == 8
            l_visited << knot unless l_visited.include?(knot)
          end
        end

        # puts "Rope: #{h_p}, #{knots.join ', '}"
      end
    end

    puts "Part 1: #{s_visited.count}"
    puts "Part 2: #{l_visited.count}"
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
  parser.on '-S', '--sample2', 'Use second sample data even if real data is available' do
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
  dir, len = *line.strip.split
  impl.input dir.downcase.to_sym, len.to_i
end

impl.output
