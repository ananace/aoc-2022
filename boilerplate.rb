#!/bin/env ruby
# frozen_string_literal: true

DAY = 1

class Implementation

end

impl = Implementation.new
open(format('day%<day>02i.inp', day: DAY)).each_line do |line|
  impl.input line
end


