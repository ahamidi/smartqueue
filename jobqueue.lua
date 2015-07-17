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
-- Helper Functions
----

-- Saves the job's payload to Redis (also handles encoding)
local function saveJobWithPayload(id, timestamp, payload)
   redis.call('ZADD', 'sq:jobs', redis.call('INCR', 'sq:jobcount'), id)
   return redis.call('HMSET', 'sq:job:'..id, "queued_at", timestamp, "status", "new", "retries", 0, "next_retry_at", 0, "payload", payload)
end

-- Retrieves the job's payload (handles decoding)
local function getJobWithPayload(id)
    local jobData = redis.call('HGETALL', 'sq:job:'..id)
    return jobData
end

----
-- Functions
----

-- Add
local function addJob(id, timestamp, payload)
    local exists = redis.call('ZSCORE', 'sq:jobs', id)
    if not exists then
        return saveJobWithPayload(id, timestamp, payload)
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
    local jobID = redis.call('ZRANGE', 'sq:jobs', 0, 0)
    if jobID[1] ~= nil then
        redis.call('ZREMRANGEBYRANK', 'sq:jobs', 0, 0)
        local job = getJobWithPayload(jobID[1])
        return cjson.encode(job)
    else
        return nil
    end
end

-- Count
local function count()
    return redis.call('ZCARD', 'sq:jobs')
end


-- Main
if command == "add" then
    return addJob(ARGV[2], ARGV[3], ARGV[4])
elseif command == "remove" then
    return removeJob(ARGV[2])
elseif command == "pop" then
    return pop()
elseif command == "peek" then
    return peek()
elseif command == "count" then
    return count()
end
