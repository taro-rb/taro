describe Taro::Types::InputType do
  it 'coerces input' do
    expect(described_class.new(nil).coerce_input).to eq({})
  end

  it 'can not be used to coerce response data' do
    expect do
      described_class.new(nil).coerce_response
    end.to raise_error(Taro::RuntimeError, /response/)
  end
end
