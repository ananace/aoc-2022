#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 13

class Implementation
  def initialize
    @data = []
  end

  def input(pair)
    @data << pair
  end

  def output
    correct = []
    @data.each.with_index do |(left, right), i|
      correct << i + 1 if compare_array(left, right) <= 0
    end

    puts "Part 1: #{correct.sum}"

    combined = []
    @data.each do |(a, b)|
      combined << a
      combined << b
    end

    d1 = [[2]]
    d2 = [[6]]
    combined << d1
    combined << d2

    combined.sort! { |a, b| compare_array a, b }

    puts "Part 2: #{(combined.index(d1) + 1) * (combined.index(d2) + 1)}"
  end

  def compare_array(left, right)
    # Deep copy arrays to make comparison easier (can modify them)
    left = Marshal.load(Marshal.dump(left))
    right = Marshal.load(Marshal.dump(right))

    while true
      return 0 if left.empty? && right.empty?
      return -1 if left.empty?
      return 1 if right.empty?

      v1 = left.shift
      v2 = right.shift

      r = compare_value(v1, v2)
      return r unless r == 0
    end
  end

  def compare_value(left, right)
    if left.is_a?(Array) && right.is_a?(Array)
      compare_array(left, right)
    elsif left.is_a?(Numeric) && right.is_a?(Numeric)
      left <=> right
    else
      left = [left] unless left.is_a?(Array)
      right = [right] unless right.is_a?(Array)
      compare_array(left, right)
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

data = []
open(input).each_line do |line|
  if line.strip.empty?
    impl.input data
    data = []
  else
    data << eval(line.strip)
  end
end
impl.input data unless data.empty?

impl.output
