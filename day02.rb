#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 2

class Implementation
  def initialize
    @prompts = []
  end

  def input(prompt, response)
    prompt = translate_input(prompt)
    response = translate_input(response)
    @prompts << [prompt, response]
  end

  def output
    result = 0

    @prompts.each do |prompt, response|
      # print "#{prompt} - #{response}"
      score = shape_score(response)

      rres = result(prompt, response)
      case rres
      when 0
        score += 3
      when 1
        score += 6
      end

      # puts " => #{score}"
      result += score
    end

    puts "Part 1: #{result}"

    @prompts.map! do |prompt, response|
      [prompt, retranslate_input(response)]
    end

    result = 0
    @prompts.each do |prompt, target|
      response = find_response(prompt, target)
      # print "#{prompt} - #{response} (#{target})"

      score = shape_score(response)

      rres = result(prompt, response)
      case rres
      when 0
        score += 3
      when 1
        score += 6
      end

      # puts " => #{score}"
      result += score
    end

    puts "Part 1: #{result}"
  end

  private

  def shape_score(shape)
    {
      rock: 1,
      paper: 2,
      scissor: 3
    }[shape]
  end

  def result(a, b)
    case a
    when :rock
      return -1 if b == :scissor
      return 1 if b == :paper
    when :paper
      return -1 if b == :rock
      return 1 if b == :scissor
    when :scissor
      return -1 if b == :paper
      return 1 if b == :rock
    end
    0
  end

  def find_response(prompt, result)
    case prompt
    when :rock
      return :rock if result == :draw
      return :paper if result == :win
      return :scissor if result == :loss
    when :paper
      return :rock if result == :loss
      return :paper if result == :draw
      return :scissor if result == :win
    when :scissor
      return :rock if result == :win
      return :paper if result == :loss
      return :scissor if result == :draw
    end
  end

  def translate_input(inp)
    case inp
    when 'A', 'X'
      :rock
    when 'B', 'Y'
      :paper
    when 'C', 'Z'
      :scissor
    end
  end

  def retranslate_input(inp)
    case inp
    when :rock
      :loss
    when :paper
      :draw
    when :scissor
      :win
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
  impl.input *line.strip.split
end

impl.output
