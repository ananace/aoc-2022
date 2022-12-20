#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 20

TrackableNumber = Struct.new :number, :garb

class Implementation
  def initialize
    @numbers = []
  end

  def input(number)
    @numbers << number
  end

  def output
    calc = @numbers.dup.map { |v| TrackableNumber.new v, rand }

    mix(calc)
    raise 'Data loss' if calc.size != @numbers.size

    mid = calc.find { |n| n.number == 0 }
    base_index = calc.index mid

    d1 = (base_index + 1000) % calc.size
    d2 = (base_index + 2000) % calc.size
    d3 = (base_index + 3000) % calc.size

    puts "Part 1: #{calc.at(d1).number + calc.at(d2).number + calc.at(d3).number}"

    calc = @numbers.dup.map { |v| TrackableNumber.new v * 811589153, rand }
    order = calc.dup
    10.times do
      mix(calc, order: order)
    end

    mid = calc.find { |n| n.number == 0 }
    base_index = calc.index mid

    d1 = (base_index + 1000) % calc.size
    d2 = (base_index + 2000) % calc.size
    d3 = (base_index + 3000) % calc.size

    puts "Part 2: #{calc.at(d1).number + calc.at(d2).number + calc.at(d3).number}"
  end

  def mix(numbers, order: nil)
    order ||= numbers.dup

    order.each do |num|
      # puts "For #{num.number} at #{numbers.index num}"
      # puts "Pre:  #{numbers.map(&:number).inspect}"

      i = numbers.index(num)

      numbers.delete num
      numbers.insert ((i + num.number) % numbers.size), num

      # puts "Post: #{numbers.map(&:number).inspect}"
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
  impl.input line.strip.to_i
end

impl.output
