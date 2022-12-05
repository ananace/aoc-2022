#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 5

class Implementation
  def initialize
    @stacks = {}
    @steps = []
  end

  def add_crate(id, crate)
    stack = (@stacks[id] ||= OpenStruct.new(
      id: id,
      name: nil,
      crates: []
    ))

    # puts "Adding #{crate.inspect} to #{id}"
    crate = crate.delete('[]').strip
    stack[:crates] << crate unless crate.strip.empty?
  end
  def finish_crates
    @stacks.each { |_, stack| stack.crates.reverse! }
  end

  def name_stack(id, name)
    # puts "Naming #{id} #{name.inspect}"
    @stacks[id].name = name
  end

  def input(line)
    m = line.match /([a-z]+)\s*([0-9]+)[a-z ]*([0-9]+)[a-z ]*([0-9]+)/

    @steps << OpenStruct.new(
      line: line,
      action: m[1],
      count: m[2].to_i,
      from: m[3],
      to: m[4]
    )
  end

  def output(ext = false)
    # Deep copy
    local_stacks = Marshal.load(Marshal.dump(@stacks))

    puts "Input;"
    print local_stacks
    puts

    @steps.each do |step|
      case step.action
      when 'move'
        from = local_stacks.find { |_, v| v.name == step.from }.last
        to = local_stacks.find { |_, v| v.name == step.to }.last

        # puts "Moving #{step.count} from #{from} to #{to}"
        if ext
          to.crates += from.crates.slice!(-step.count, step.count)
        else
          step.count.times {
            raise 'Ran out of crates' if from.crates.empty?

            to.crates.push from.crates.pop
          }
        end
      end

      # puts step.line
      # print local_stacks
      # puts
    end

    puts "Result;"
    print local_stacks

    local_stacks.map { |_, s| s.crates.last }.join
  end

  private 

  def print(stacks = @stacks)
    puts stacks.map { |id, s| "#{s.name}: #{s.crates.join ', '}" }
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

stage = :crate
open(input).each_line do |line|
  case stage
  when :crate
    unless line.include? '['
      impl.finish_crates
      stage = :stack
      redo
    end

    line.scan(/(.{3})(?:\s|$)/).each.with_index do |crate, id|
      impl.add_crate id, *crate
    end
  when :stack
    if line.strip.empty?
      stage = :action
      next
    end

    line.strip.split.each.with_index do |name, id|
      impl.name_stack id, name
    end
  when :action
    impl.input line.strip
  end
end

puts
puts "Part 1: #{impl.output}"
puts
puts "Part 2: #{impl.output(true)}"
