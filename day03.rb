#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 3

class Implementation
  def initialize
    @sacks = []
  end

  def input(line)
    @sacks << [line[0, line.size/2], line[line.size/2..]]
  end

  def output
    total = @sacks.sum do |sack|
      same = find_same(sack)

      # puts "Sack: #{sack} -> #{same}"

      calc_sum(same)
    end
    puts "Part 1: #{total}"

    total = 0
    @sacks.each_slice(3).with_index do |sacks, i|
      sacks = sacks.map { |c1, c2| (c1 + c2).chars }

      same = sacks.first.select { |c| sacks[1].include?(c) && sacks[2].include?(c) }.uniq
      # puts "Group #{i}: #{same}"

      total += calc_sum(same)
    end
    puts "Part 2: #{total}"
  end

  private

  def find_same(sack)
    sack.first.chars.select { |c| sack.last.chars.include? c }.uniq
  end

  def calc_sum(chars)
    chars.sum { |c| (c =~ /[a-z]/ ? c.bytes.first - 96 : 26 + c.bytes.first - 64) }
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
