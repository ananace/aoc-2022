#!/bin/env ruby
# frozen_string_literal: true

require 'ostruct'
require 'set'

$args = OpenStruct.new

#
# Daily challenge
#

DAY = 16

class Array
  def avg
    sum / size
  end
end

Valve = Struct.new :name, :flow

PathNode = Struct.new :name, :parent do
  def full_path
    return [name] unless parent

    parent.full_path + [name]
  end
end
Actor = Struct.new :at, :time, :pressure, :open

class Implementation
  def initialize
    @valves = {}
    @links = {}
  end

  def input(valve, links)
    @valves[valve.name] = valve.flow
    @links[valve.name] = links
  end

  def output
    at = 'AA'
    minutes = 30

    start = Actor.new at, 0, 0, Set.new(['AA'])

    puts "Calculating potential solutions... (Will take a while)"
    puts "Part 1: #{calc_potential(start, minutes)}"
    puts "Part 2: #{calc_potential_friend(start, minutes - 4)}"
  end

  def graph
    @graph ||= begin
      g = {}
      # No need to ever interact with zero-flow valves, so don't include them in the graph
      (@valves.reject { |_, flow| flow.zero? }.map(&:first) + ['AA']).each do |v|
        g[v] = (@valves.reject { |_, flow| flow.zero? }.map(&:first) + ['AA']).map do |v2|
          [v2, find_path(v, v2).size]
        end.sort_by(&:last).to_h
      end
      g
    end
  end

  # RRT-like imperative potential calculation
  def calc_potential(actor, minutes, graph: self.graph)
    max_pressure = 0

    potentials = [actor]
    until potentials.empty?
      potential = potentials.shift

      (graph.keys - potential.open.to_a).each do |valve|
        dist = graph[potential.at][valve]
        next if dist >= minutes - potential.time

        new = potential.dup.tap do |new|
          new.at = valve
          new.pressure += @valves[valve] * (minutes - new.time - dist)
          new.time += dist
          new.open = new.open + [valve]
        end
        potentials << new
        max_pressure = new.pressure if new.pressure > max_pressure
      end
    end

    max_pressure
  end

  def calc_potential_friend(actor, minutes)
    max_pressure = 0

    valves = graph.keys.reject { |k| k == 'AA' }
    valves.combination(valves.size / 2) do |permutation|
      val = calc_potential(actor, minutes, graph: graph.select { |k, _| permutation.include?(k) || k == 'AA' }) +
            calc_potential(actor, minutes, graph: graph.select { |k, _| !permutation.include?(k) || k == 'AA' })

      max_pressure = val if val > max_pressure
    end

    max_pressure
  end

  # Flood-fill pathfinding, copied from day 12
  def find_path(from, to)
    from = from.name if from.is_a? Valve
    to = to.name if to.is_a? Valve

    visited = Set.new
    to_visit = []
    to_visit << PathNode.new(from)

    until to_visit.empty?
      cur = to_visit.shift
      return cur.full_path if cur.name == to

      @links[cur.name].each do |link|
        next if visited.include? link

        visited << link
        to_visit << PathNode.new(link, cur)
      end
    end

    raise 'Unable to find path'
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
  name, rate, links = *line.scan(/^valve (.*) has.*rate=(\d+).*valves? (.*)$/i).flatten
  links = links.split(',').map(&:strip)
  impl.input Valve.new(name, rate.to_i), links
end

impl.output
