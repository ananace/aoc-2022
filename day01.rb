#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 1

class Implementation
  def initialize
    @elves = {}
  end

  def input(data, id)
    # puts "Adding #{data}C to #{id}"
    @elves[id] ||= 0
    @elves[id] += data
  end

  def output
    puts "Part 1: #{@elves.map { |k, d| d }.max}"
    puts "Part 2: #{@elves.map { |k, d| d }.sort[-3..].sum}"
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

elf = 0
open(input).each_line do |line|
  if line.strip.empty?
    elf += 1
  else
    impl.input line.to_i, elf
  end
end

impl.output
