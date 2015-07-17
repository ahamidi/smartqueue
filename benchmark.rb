#! /usr/bin/env ruby

require "thor"
require "redis"
require "time"
require "digest/sha1"
require "oj"
require "./sqcli"

# Helper Functions

def generate_payload()
  return get_random_json_payload(4, 10)  
end

def get_random_string(character_count)
  o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten

  (0...character_count).map{ o[rand(o.length)] }.join
end

def get_random_json_payload(number_of_fields, field_size)
  fields = {}
  # Generate payload hash
  (1..number_of_fields).each do |field_number|
    fields['field_'+field_number.to_s] = get_random_string(field_size)
  end

  Oj.dump(fields)
end


class SQBench < SQCLI
  
  desc "w JOB_COUNT", "run write benchmark"
  def w(jobs=1000)
    puts "Initializing Benchmark"
    sha = load()
    puts "Running..."
    tStart = Time.now
    jobs.to_i.times { |i|
      add(i, generate_payload())
    }
    runTime = (Time.now - tStart)
    opsPerSec = (jobs.to_i/runTime).to_i
    puts "Took #{runTime.to_s} seconds (#{opsPerSec}/s)." 
  end
  
  desc "r JOB_COUNT", "run read benchmark"
  def r(jobs=1000)
    puts "Initializing Benchmark"
    sha = load()
    puts "Running..."
    tStart = Time.now
    jobs.to_i.times { |i|
      add(i, generate_payload())
    }
    jobs.to_i.times {
      pop()
    }
    runTime = (Time.now - tStart)
    opsPerSec = (jobs.to_i/runTime).to_i
    puts "Took #{runTime.to_s} seconds (#{opsPerSec}/s)." 
  end

  desc "rw JOB_COUNT", "run read/write benchmark"
  def rw(jobs=1000)
    puts "Initializing Benchmark"
    sha = load()
    puts "Running..."
    tStart = Time.now
    jobs.to_i.times { |i|
      Random.rand(1.0)>0.5 ? add(i, generate_payload()) : pop()
    }
    runTime = (Time.now - tStart)
    opsPerSec = (jobs.to_i/runTime).to_i
    puts "Took #{runTime.to_s} seconds (#{opsPerSec}/s)." 
  end 
end

SQBench.start(ARGV)
