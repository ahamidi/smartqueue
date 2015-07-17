### SmartQueue - Ordered Set Job Queue

#### TODO
- [x] Support JSON job data
- [ ] Store rolling stats on jobs
- [ ] Support keys on all commands (cluster)
- [ ] Docs
- [ ] Tests
- [ ] SDK(s)?
- [x] Benchmarks (SEE benchmark.rb)

#### Usage
SmartQueue is (expected to be) used via an SDK

- [Go](http://github.com/ahamidi/go-sq)

To test via included SQCLI:
```
./sqcli.rb
```

#### Notes

##### Job Data
Accept JSON data along with Jobs, save in separate key (so that it can be sharded across cluster).

##### Performance
All functions ultimately map to Redis ordered set commands that are O(log(N)) complexity or better.

##### JSON Data
Each job's data is stored separately as a hash with the following fields, with the key being the Job ID (with the prefix "sq:job:"):

* queued_at (timestamp)
* status (string)
* retries (int)
* next_retry_at (timestamp)
* payload (blob)
