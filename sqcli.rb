#! /usr/bin/env ruby

require "thor"
require "redis"
require "time"
require "digest/sha1"

def readScript
  sqScript = ""
    File.open("./jobqueue.lua", "r") do |f|
      f.each_char do |char|
        sqScript << char
      end
    end
  return sqScript
end

def shaScript(file)
  return Digest::SHA1.hexdigest file
end

class SQCLI < Thor
  
  desc "load HOST PORT", "load SmartQueue script"
  def load(host="localhost", port=6379)
    redis = Redis.new(host: host, port: port, db:2)
    sha = redis.script(:load, readScript())
    puts sha
  end

  desc "add ID PAYLOAD", "add Job"
  def add(id, payload, host="localhost", port=6379)
    redis = Redis.new(host: host, port: port, db:2)
    sha = shaScript(readScript())
    result = redis.evalsha(sha, nil, ["add", id, Time.new.to_i, payload])
    puts result
  end

  desc "count", "count jobs in queue"
  def count(host="localhost", port=6379)
    redis = Redis.new(host: host, port: port, db:2)
    sha = shaScript(readScript())    
    result = redis.evalsha(sha, nil, ["count"])
    puts result
  end

  desc "remove ID", "remove job with ID from queue"
  def remove(id, host="localhost", port=6379)
    redis = Redis.new(host: host, port: port, db:2)
    sha = shaScript(readScript())    
    result = redis.evalsha(sha, nil, ["remove", id])
    puts result
  end

  desc "pop", "get next available job"
  def pop(host="localhost", port=6379)
    redis = Redis.new(host: host, port: port, db:2)
    sha = shaScript(readScript())   
    result = redis.evalsha(sha, nil, ["pop"])
    puts result
  end

end

SQCLI.start(ARGV)
