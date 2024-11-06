task :benchmark do
  require 'benchmark/ips'
  require 'json'
  require_relative '../lib/taro'

  data = JSON.load_file("#{__dir__}/benchmark_1kb.json")

  item_type = Class.new(Taro::Types::ObjectType) do
    field(:name) { [String, null: false] }
    field(:language) { [String, null: false] }
    field(:id) { [String, null: false] }
    field(:bio) { [String, null: false] }
    field(:version) { [Float, null: false] }
  end

  type = item_type.list

  # 87.804k (± 1.7%) i/s -    446.811k in   5.090218s
  Benchmark.ips do |x|
    x.report('parse 1 KB of params') { type.new(data).coerce_input }
  end

  # 82.952k (± 3.9%) i/s -    419.650k in   5.067859s
  Benchmark.ips do |x|
    x.report('validate a 1 KB response') { type.new(data).coerce_response }
  end

  big_data = data * 1000
  big_data.each { |el| el.merge('version' => rand) }

  # 78.570 (± 1.3%) i/s -    399.000 in   5.080019s
  Benchmark.ips do |x|
    x.report('parse 1 MB of params') { type.new(big_data).coerce_input }
  end

  # 74.192 (± 2.7%) i/s -    371.000 in   5.004312s
  Benchmark.ips do |x|
    x.report('validate a 1 MB response') { type.new(big_data).coerce_response }
  end
end
