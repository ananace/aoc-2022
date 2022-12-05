#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

module RangeExt
  def overlap?(range)
    include?(range.first) || include?(range.last) || \
      range.include?(first) || range.include?(last)
  end

  def fully_contain?(range)
    (include?(range.first) && include?(range.last)) || \
      (range.include?(first) && range.include?(last))
  end
end

Range.prepend RangeExt

#
# Daily challenge
#

DAY = 4

class Implementation
  def initialize
    @pairs = []
  end

  def input(a, b)
    @pairs << [a, b]
  end

  def output
    fully_contained_count = @pairs.count do |a, b|
      contained = a.fully_contain?(b) || b.fully_contain?(a)

      contained
    end

    puts "Part 1: #{fully_contained_count}"

    intersecting_count = @pairs.count { |a, b| a.overlap? b }

    puts "Part 2: #{intersecting_count}"
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
  a, b = line.strip.split(',').map { |range| Range.new(*range.split('-').map(&:to_i)) }
  impl.input a, b
end

impl.output
