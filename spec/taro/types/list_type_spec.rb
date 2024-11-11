describe Taro::Types::ListType do
  let(:example) { described_class.for(S::StringType) }

  it 'coerces input' do
    expect(example.new(%w[a]).coerce_input).to eq %w[a]
    expect(example.new([]).coerce_input).to eq []
    expect { example.new([42]).coerce_input }
      .to raise_error(Taro::InputError, /must be a String/)
    expect { example.new('a').coerce_input }
      .to raise_error(Taro::InputError, /must be an Array/)
  end

  it 'coerces response data' do
    expect(example.new(%w[a]).coerce_response).to eq %w[a]
    expect(example.new([]).coerce_response).to eq []
    expect { example.new('a').coerce_response }
      .to raise_error(Taro::ResponseError, /must be an Enumerable/)
    expect { example.new(1.1).coerce_response }
      .to raise_error(Taro::ResponseError, /must be an Enumerable/)
  end
end
