class StatsCollector

  def initialize
    @data_set_config = {}
  end

  def self.perform(data_sets: [])
    inst = new.prepare(data_sets: data_sets)
    yield(inst)
    inst
  end

  def prepare(data_sets: [])
    data_sets.each_with_object(@data_set_config) do |e, h|
      h[e.name] = e
    end
    self
  end

  def report(report_for: '', data: nil)
    @data_set_config[report_for].collect(data: data)
  end

  def generate_stats
    result = {}
    @data_set_config.each do |k, v|
      result[k] = v.generate_stats
    end
    result
  end

end

class StatsDataSet

  attr_reader :name

  def initialize(name: '')
    @name = name
    @data_set = Concurrent::Array.new
  end

  def self.define_metrics(name: 'rpm')
    new(name: name)
  end

  def collect(data: nil)
    @data_set << data
  end

  def generate_stats
    stats = StatsGenerator.new(data_set: @data_set)
    OpenStruct.new(
      sample_count: stats.sample_count,
      sum: stats.sum,
      average: stats.average,
      minimum: stats.minimum,
      percentile_95: stats.percentile,
      mean: stats.mean,
      median: stats.median,
      variance: stats.variance,
      standard_deviation: stats.standard_deviation
    )
  end
end

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Statistics-definitions.html
# inspired from this

class StatsGenerator

  def initialize(data_set:)
    @data_set = data_set
    @compact_data_set = @data_set.compact
  end

  def sample_count
    @data_set.size
  end

  def sum
    @compact_data_set.sum
  end

  def average
    sum/sample_count
  end

  def minimum
    @compact_data_set.min
  end

  def maximum
    @compact_data_set.max
  end

  def percentile(p = 95)
    values = @compact_data_set.dup

    return 0 if values.empty?
    return values.first if values.size == 1

    values.sort!
    return values.last if p == 100
    rank = p / 100.0 * (values.size - 1)
    lower, upper = values[rank.floor,2]
    lower + (upper - lower) * (rank - rank.floor)
  end

  def trimmed_percentile
  end

  def winsorized_mean
  end

  def percentile_rank(p = 0)
    values = @compact_data_set.dup
    return 0 if values.empty?
    return 100 if values.size == 1
    values.sort!
    (((values.sort.rindex { |x| x <= p } || -1.0) + 1.0)) / values.size * 100.0
  end

  def trimmed_count
  end

  def trimmed_sum
  end

  def mean
    values = @compact_data_set.dup
    return 0 if values.empty?
    return values.first if values.size == 1
    values.sum / values.size
  end

  def median
    percentile(50)
  end

  def variance
    values = @compact_data_set.dup
    return 0 if values.empty?
    values.map { |sample| (mean - sample) ** 2 }.reduce(:+) / values.size
  end

  def standard_deviation
    values = @compact_data_set.dup
    return 0 if values.empty?
    Math.sqrt(variance)
  end
end