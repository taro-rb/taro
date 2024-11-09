describe Taro::Types::ListType do
  let(:example) { described_class.for(S::StringType) }

  it 'coerces input' do
    expect(example.new(%w[a]).coerce_input).to eq %w[a]
    expect(example.new([]).coerce_input).to eq []
    expect(example.new([42]).coerce_input).to be_nil
    expect(example.new('a').coerce_input).to be_nil
  end

  it 'coerces response data' do
    expect(example.new(%w[a]).coerce_response).to eq %w[a]
    expect(example.new([]).coerce_response).to eq []
    expect(example.new('a').coerce_response).to eq %w[a]
    expect(example.new(1.1).coerce_response).to be_nil
  end
end
