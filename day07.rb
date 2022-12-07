#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 7

class Implementation
  def initialize
    @path = '~'
    @executing = nil

    @tree = []
  end

  def input(line)
    cmd, *args = line.sub('$', '').strip.split
    if line.start_with? '$'
      @executing = nil

      case cmd
      when 'cd'
        @path = if args.first.start_with? '/'
                  args.first
                else
                  File.expand_path(File.join(@path, args.first))
                end
        # puts "Changed path to #{@path}"
      when 'ls'
        @executing = :ls
        # puts "Running ls in #{@path}"
      end
    else
      return if cmd == 'dir'

      size = cmd.to_i
      file = args.first

      @tree << {
        path: File.join(@path, file),
        size: size.to_i
      }
    end
  end

  def output
    @common = {}

    @tree.each do |entry|
      dir = File.dirname(entry[:path])
      @common[dir] ||= 0
      @common[dir] += entry[:size]
    end

    # puts @common

    # Duplicate the hash to avoid modifying the original during iteration
    copy = @common.dup
    copy.each do |path, size|
      subpath = path
      until subpath == '/'
        subpath = File.dirname subpath

        @common[subpath] ||= 0
        @common[subpath] += size
      end
    end

    puts "Part 1: #{@common.select { |_, size| size <= 100_000 }.sum { |_, size| size }}"

    total = 700_000_00
    wanted = 300_000_00
    free = total - @common['/']

    puts "Part 2: #{@common.map(&:last).sort.find { |size| free + size >= wanted }}"
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
