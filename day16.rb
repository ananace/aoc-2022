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
Action = Struct.new :target, :distance do
  def busy?
    distance > 0
  end
end

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
    pressure = 0

    # puts "Graph complexity; #{graph.map { |_, v| v.size }.avg}"

    puts "Calculating potential solutions... (Will take a while)"
    puts "Part 1: #{calc_potential(Action.new('AA', 0), Set.new, 0, 30)}"
    puts "Part 2: #{calc_potential_friend(Action.new('AA', 0), Action.new('AA', 0), Set.new, 0, 26)}"
  end

  def graph
    @graph ||= begin
      g = {}
      # No need to ever interact with zero-flow valves, so don't include them in the graph
      (@valves.reject { |_, flow| flow.zero? }.map(&:first) + ['AA']).each do |v|
        g[v] = (@valves.reject { |_, flow| flow.zero? }.map(&:first) + ['AA']).map do |v2|
          [v2, find_path(v, v2).size]
        end
      end
      g
    end
  end

  # RRT-like recursive potential calculation
  def calc_potential(you, open, pressure, minutes)
    return pressure if minutes == 0
    while you.busy?
      you.distance -= 1
      minutes -= 1
    end

    best = pressure

    for link, dist in graph[you.target]
      next if open.include? link
      next if dist >= minutes

      res = calc_potential(
        Action.new(link, dist),
        open + [link],
        pressure + @valves[link] * (minutes - dist),
        minutes
      )

      best = res if res > best
    end

    best
  end

  # XXX Should be reasonably simple to thread this for a good performance boost
  def calc_potential_friend(you, elephant, open, pressure, minutes)
    return pressure if minutes == 0
    # Both of you are busy moving
    while you.busy? && elephant.busy?
      you.distance -= 1
      elephant.distance -= 1
      minutes -= 1
    end

    best = pressure

    # You are able to perform an action
    unless you.busy?
      moving = false
      for link, dist in graph[you.target]
        next if open.include? link
        next if dist >= minutes

        moving = true
        res = calc_potential_friend(
          Action.new(link, dist),
          elephant.dup,
          open + [link],
          pressure + @valves[link] * (minutes - dist),
          minutes
        )

        best = res if res > best
      end

      return best if moving
    end

    # The elephant is able to perform an action
    unless elephant.busy?
      for link, dist in graph[elephant.target]
        next if open.include? link
        next if dist >= minutes

        res = calc_potential_friend(
          you.dup,
          Action.new(link, dist),
          open + [link],
          pressure + @valves[link] * (minutes - dist),
          minutes
        )

        best = res if res > best
      end
    end

    best
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
