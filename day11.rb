#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 11

class OperValue
  attr_accessor :input, :output

  def initialize(value)
    @input = value
    @output = 0
  end

  def self.calc(value, operation)
    input = value
    output = 0

    eval operation

    output
  end
end

class Implementation
  def initialize
    @program = []
  end

  def input(monkey, program)
    program[:monkey] = monkey
    @program << program
  end

  def output
    data = Marshal.load(Marshal.dump(@program))

    20.times do
      calc_round data, divide: 3
    end

    times = data.map { |m| m[:storage][:times] }.sort.reverse
    puts times.inspect
    puts "Part 1: #{times.first * times[1]}"

    data = Marshal.load(Marshal.dump(@program))
    gr_div = data.map { |m| m[:test][:operand] }.inject(1) { |a, v| v *= a }
    
    puts '[Working...' + ' ' * 90 + ']'
    print '['
    10_000.times do |i|
      print '.' if i % 100 == 0
      calc_round data, modulo: gr_div
    end
    puts ']'

    times = data.map { |m| m[:storage][:times] }.sort.reverse
    puts times.inspect
    puts "Part 2: #{times.first * times[1]}"
  end

  def calc_round(data, divide: nil, modulo: nil)
    data.each do |program|
      monkey = program[:monkey]
      # puts "Monkey #{monkey}:"
      storage = (program[:storage] ||= {})

      program[:items].each do |item|
        storage[:times] = (storage[:times] || 0) + 1
        inspection = OperValue.calc(item, program[:operation])

        # puts "  Inspects #{item} with #{program[:operation]}, changing it to #{inspection}"

        if divide
          inspection /= divide
          # puts "  lowers to #{inspection}"
        elsif modulo
          inspection %= modulo
          # puts "  lowers to #{inspection}"
        end

        target = nil
        case program[:test][:operation]
        when :divisible
          if inspection % program[:test][:operand] == 0
            target = program[:if_true][:target]
          else
            target = program[:if_false][:target]
          end
        end

        # puts "  tosses to #{target}"
        data[target][:items] << inspection
      end
      program[:items] = []
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

state = :monkey
monkey = nil
program = nil
open(input).each_line do |line|
  case state
  when :monkey
    monkey = line.scan(/(\d):/).flatten.first.to_i
    program = {}
    state = :program
  when :program
    if line.strip.empty?
      impl.input monkey, program
      state = :monkey
      next
    end
    op, data = *line.strip.split(':').map(&:strip)

    case op
    when /starting items/i
      data = data.split(',').map(&:to_i)
      op = 'items'
    when /operation/i
      data = data.gsub('old', 'input').gsub('new', 'output')
    when /test/i
      oper, value = *data.scan(/(.*)\s+by(.*)/i).flatten
      oper = oper.to_sym
      value = value.to_i
      data = {
        operation: oper,
        operand: value
      }
    when /if /i
      op = op.sub(' ', '_')
      target = data.scan(/monkey (.*)/i).flatten.first.to_i
      data = {
        target: target
      }
    end

    program[op.downcase.to_sym] = data
  end
end
impl.input monkey, program

impl.output
