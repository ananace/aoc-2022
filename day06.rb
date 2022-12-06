#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 6

class Implementation
  def initialize
    @lines = []
  end

  def input(line)
    @lines << line
  end

  def output
    @lines.each do |line|
      buf = []

      line.each_char.with_index do |c, id|
        buf << c

        next unless buf.size >= 4
        buf.shift if buf.size > 4

        next if buf.any? { |c| buf.count(c) > 1 }

        puts "#{buf.join} is unique at #{id + 1}"
        break
      end

      buf = []
      line.each_char.with_index do |c, id|
        buf << c

        next unless buf.size >= 14
        buf.shift if buf.size > 14

        next if buf.any? { |c| buf.count(c) > 1 }

        puts "#{buf.join} is unique at #{id + 1}"
        break
      end
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
  impl.input line.strip
end

impl.output
