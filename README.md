### SmartQueue - Ordered Set Job Queue

#### TODO
- [ ] - Support JSON job data
- [ ] - Store rolling stats on jobs
- [ ] - Support keys on all commands (cluster)
- [ ] - Docs
- [ ] - Tests
- [ ] - SDK(s)?
- [ ] - Benchmarks

#### Performance

All functions ultimately map to Redis ordered set commands that are O(log(N)) complexity or better.

#### Notes

##### Job Data
Accept JSON data along with Jobs, save in separate key (so that it can be sharded across cluster).
