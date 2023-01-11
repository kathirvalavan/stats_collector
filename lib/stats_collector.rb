
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
end