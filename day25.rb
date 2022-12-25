#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 25

SNAFU = Struct.new :number do
  def to_i
    parts = number.chars.reverse.map.with_index do |num, i|
      case num
      when '-'
        num = -1
      when '='
        num = -2
      end
      num.to_i * 5**i
    end

    parts.sum
  end

  def to_s
    number
  end
end

class Integer
  def to_snafu
    result = ''

    overflow = nil
    to_s(5).chars.reverse.map(&:to_i).each do |i|
      if overflow
        i += overflow
        overflow = nil
      end

      result += '0' if i > 4

      if i > 2
        case i - 5
        when -1
          result += '-'
        when -2
          result += '='
        end

        overflow ||= 0
        overflow += 1
      else
        result += i.to_s
      end
    end

    if overflow
      result += overflow.to_s
    end

    result = result.reverse

    SNAFU.new result
  end
end

class Implementation
  def initialize
    @numbers = []
  end

  def input(line)
    @numbers << SNAFU.new(line)
  end

  def output
    sum = @numbers.map(&:to_i).sum
    puts "Part 1: #{sum.to_snafu} (#{sum})"
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
