task :benchmark do
  require 'benchmark/ips'
  require 'json'
  require_relative '../lib/taro'

  data = JSON.load_file("#{__dir__}/benchmark_1kb.json", symbolize_names: true)

  item_type = Class.new(Taro::Types::ObjectType) do
    field :name, type: 'String', null: false
    field :language, type: 'String', null: false
    field :id, type: 'String', null: false
    field :bio, type: 'String', null: false
    field :version, type: 'Float', null: false
  end

  type = Taro::Types::ListType.for(item_type)

  # 143.889k (± 2.7%) i/s -    723.816k in   5.034247s
  Benchmark.ips do |x|
    x.report('parse 1 KB of params') { type.new(data).coerce_input }
  end

  # 103.382k (± 6.5%) i/s -    522.550k in   5.087725s
  Benchmark.ips do |x|
    x.report('validate a 1 KB response') { type.new(data).coerce_response }
  end

  big_data = data * 1000
  big_data.each { |el| el.merge('version' => rand) }

  # 101.359 (± 5.9%) i/s -    513.000 in   5.078335s
  Benchmark.ips do |x|
    x.report('parse 1 MB of params') { type.new(big_data).coerce_input }
  end

  # 84.412 (± 2.4%) i/s -    427.000 in   5.061117s
  Benchmark.ips do |x|
    x.report('validate a 1 MB response') { type.new(big_data).coerce_response }
  end
end
