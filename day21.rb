#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 21

Monkey = Struct.new :name, :task do
  def finished?
    !task.is_a? String
  end
end

class Implementation
  def initialize
    @monkeys = {}
  end

  def input(monkey, task)
    monkey = monkey.to_sym
    @monkeys[monkey] = Monkey.new monkey, task
  end

  def output
    data = Marshal.load(Marshal.dump(@monkeys))

    monkey_business data
    puts "Part 1: #{data[:root].task}"

    max = data[:root].task

    data = Marshal.load(Marshal.dump(@monkeys))
    data[:root].task.sub!(%r{[/*+-]}, '=')
    data[:humn].task = 'X'

    monkey_business data, skip: [:humn]

    task = data[:root].task
    modified = true
    while modified
      modified = false

      data.each do |k, v|
        next unless task.include? k.to_s

        task = task.sub(k.to_s, "(#{v.task})")
        modified = true
      end
    end

    puts task

    # TODO Actually solve the equation locally

    exit
    puts "Part 2: #{}"
  end

  def monkey_business(data, skip: [])
    modified = true
    while modified
      modified = false
      data.each do |k, m|
        next if skip.include? k

        case m.task
        when /^\d+$/
          m.task = m.task.to_i
          modified = true
        when %r{^(\w+) ([/*+-=]) (\w+)$}
          lhs = $1
          op = $2
          rhs = $3

          if lhs.to_i.to_s == lhs
            lhs = lhs.to_i
          else
            lhs = lhs.to_sym
            lhs = data[lhs].task if data[lhs].finished?
          end
          if rhs.to_i.to_s == rhs
            rhs = rhs.to_i
          else
            rhs = rhs.to_sym
            rhs = data[rhs].task if data[rhs].finished?
          end

          if lhs.is_a?(Symbol) || rhs.is_a?(Symbol)
            new_task = "#{lhs} #{op} #{rhs}"
            modified = true if m.task != new_task
            m.task = new_task
          else
            case op
            when '+'
              m.task = lhs + rhs
            when '-'
              m.task = lhs - rhs
            when '*'
              m.task = lhs * rhs
            when '/'
              m.task = lhs / rhs
            when '='
              m.task = lhs == rhs
            end
            modified = true
          end
        end
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
  impl.input *line.split(':').map(&:strip)
end

impl.output
