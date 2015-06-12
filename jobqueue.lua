-- Smart Job Queue
--
-- Author: Ali Hamidi <ahamidi.com>
--
-- Manage queued update jobs and enforces
-- job ordering and uniqueness.
-----------------------------------------

local command = ARGV[1]
local jobsKey = KEYS[1]
local jobsCounter = KEYS[2]

----
-- Functions
----

-- Add
local function addJob(id)
    local exists = redis.call('ZSCORE', 'sq:jobs', id)
    if not exists then
        return redis.call('ZADD', 'sq:jobs', redis.call('INCR', 'sq:jobcount'), id)
    end
end

-- Delete
local function removeJob(id)
    return redis.call('ZREM', 'sq:jobs', id)
end

-- Peek
local function peek()
    return redis.call('ZRANGE', 'sq:jobs', 0, 0)
end

-- Pop
local function pop()
    local job = redis.call('ZRANGE', 'sq:jobs', 0, 0)
    redis.call('ZREMRANGEBYRANK', 'sq:jobs', 0, 0)
    return job
end

-- Count
local function count()
    return redis.call('ZCARD', 'sq:jobs')
end


-- Main
if command == "add" then
    return addJob(ARGV[2])
elseif command == "remove" then
    return removeJob(ARGV[2])
elseif command == "pop" then
    return pop()
elseif command == "peek" then
    return peek()
elseif command == "count" then
    return count()
end
