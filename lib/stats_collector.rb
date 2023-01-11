
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
    @data_set_config.each do |_, v|
      v.generate_stats
    end
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
    stats.sample_count
  end
end

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Statistics-definitions.html
# inspired from this

class StatsGenerator

  def initialize(data_set: )
    @data_set = data_set
  end

  def sample_count
  end

  def sum
  end

  def average
  end

  def minimum
  end

  def maximum
  end

  def percentile
  end

  def trimmed_percentile
  end

  def winsorized_mean
  end

  def percentile_rank
  end

  def trimmed_count
  end

  def trimmed_sum
  end

end


