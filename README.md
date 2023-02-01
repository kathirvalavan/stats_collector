## Stats Collector

At macro level, **[Aws Cloudwatch metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Statistics-definitions.html)** comes handy while debugging our infra and analysing our systems performance. Metrics such as  **SampleCount**, **Percentile** helps us to take objective decision.
At micro level, we frequently come across situation where we need to measure performance of various  code blocks or segments in our day to day development activities..
So created **StatsCollector** which stores data and generates stats out of it.

## Usage

```
result = StatsCollector.perform(data_sets: [StatsDataSet.define_metrics(name: 'query_time'),  
  StatsDataSet.define_metrics(name: 'likes_count')]) do |collector|  
  users.each do |user|  
    user.posts.each do |post|  
      start_time = Time.now.to_i  
      likes_count = post.likes  
      collector.report(report_for: 'query_time', data: Time.now.to_i - start_time)  
      collector.report(report_for: 'likes_count', data: likes_count)  
    end  
 endend
####

stats = result.generate_stats  
stats['query_time'].sum # 100  
stats['query_time'].average # 1  
stats['query_time'].minimum # 1
stats['likes_count'].sum # 10000
stats['likes_count'].average # 10 
stats['likes_count'].minimum # 0

```
### Available Stats

- sample_count
- average
- minimum
- percentile_95
- mean
- median
- variance
- standard_deviation

**Inspired from**


- [Ruby Benchmark](https://github.com/ruby/benchmark)
- [Aws Cloudwatch metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Statistics-definitions.html)