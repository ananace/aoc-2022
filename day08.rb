#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 8

class Implementation
  def initialize
    @trees = []
    @width = 0
  end

  def input(line)
    @trees += line.chars.map(&:to_i)
    @width = line.size
  end

  def output
    show
    puts

    top = 0
    sum = 0
    for x in 0..(@width-1)
      for y in 0..(@width-1)
        cur = get x, y

        visible = visible? x, y
        score = score? x, y
        # puts "Tree at #{x}, #{y} is visible #{visible} with score #{score}"

        top = score if score > top
        sum += 1 if visible
      end
    end

    puts "Part 1: #{sum}"
    puts "Part 2: #{top}"
  end

  def get(x, y)
    return unless x >= 0 && y >= 0 && x < @width && y < @width

    @trees[y * @width + x]
  end

  def visible?(x, y)
    return true if x == 0 || y == 0 || x == @width - 1 || y == @width - 1

    tree = get x, y

    v = true
    for x2 in 0..(x - 1)
      v &&= get(x2, y) < tree
    end
    return true if v

    v = true
    for x2 in (x + 1)..(@width - 1)
      v &&= get(x2, y) < tree
    end
    return true if v

    v = true
    for y2 in 0..(y - 1)
      v &&= get(x, y2) < tree
    end
    return true if v

    v = true
    for y2 in (y + 1)..(@width - 1)
      v &&= get(x, y2) < tree
    end

    v
  end

  def score?(x, y)
    return 0 if x == 0 || y == 0 || x == @width - 1 || y == @width - 1

    tree = get x, y
    scores = []

    score = 0
    for y2 in (0..(y - 1)).to_a.reverse
      score += 1

      break if get(x, y2) >= tree
    end
    scores << score

    score = 0
    for x2 in (0..(x - 1)).to_a.reverse
      score += 1 

      break if get(x2, y) >= tree
    end
    scores << score

    score = 0
    for y2 in (y + 1)..(@width - 1)
      score += 1

      break if get(x, y2) >= tree
    end
    scores << score

    score = 0
    for x2 in (x + 1)..(@width - 1)
      score += 1

      break if get(x2, y) >= tree
    end
    scores << score

    scores.inject(1) { |s, v| v *= s }
  end

  private

  def show
    @trees.each.with_index do |tree, i|
      x = i % @width
      y = (i / @width).to_i

      print "\e[1m" if visible? x, y
      print tree
      print "\e[0m"
      print "\n" if x == @width - 1
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
