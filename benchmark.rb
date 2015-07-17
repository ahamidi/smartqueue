#! /usr/bin/env ruby

require "thor"
require "redis"
require "time"
require "digest/sha1"
require "./sqcli"

class SQBench < SQCLI
  
  desc "bench", "run benchmark"
  def bench()
    puts "Initializing Benchmark"
    sha = load()
    puts "Running..."
  end
  
end

SQBench.start(ARGV)
