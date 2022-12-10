#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

Operation = Struct.new :op, :args do
  def cycles
    return 1 if op == :noop
    return 2 if op == :addx

    raise 'Unknown operation'
  end
end

#
# Daily challenge
#

DAY = 10

class Implementation
  def initialize
    @program = []
  end

  def input(operation, *args)
    operation = operation.to_sym
    args = args.map(&:to_i)

    @program << Operation.new(
      operation,
      args
    )
  end

  INTERVALS = [20, 60, 100, 140, 180, 220]

  def output
    reg = OpenStruct.new(
      x: 1
    )
    datapoints = {}
    image = []
    cycle = 1

    line = ''
    @program.each do |op|
      pre_op = cycle.dup

      op.cycles.times do |i|
        x_pos = (cycle % 40) - 1
        line += (x_pos - reg.x).abs <= 1 ? '#' : '.'
        datapoints[cycle] = reg.x if INTERVALS.include? cycle
        cycle += 1
        next unless line.size == 40

        image << line
        line = ''
      end
      # puts "After cycle #{cycle} (executing #{op} since #{pre_op}, regs: #{reg})"

      reg.x += op.args.first if op.op == :addx
    end

    puts "Part 1: #{datapoints.map { |k, v| k * v }.sum}"
    puts image.join "\n"
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
  impl.input *line.strip.split
end

impl.output
