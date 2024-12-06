describe Taro::Types::ResponseType do
  it 'coerces responses' do
    expect(described_class.new(nil).coerce_response).to eq({})
  end

  it 'can not be used to coerce input data' do
    expect do
      described_class.new(nil).coerce_input
    end.to raise_error(Taro::RuntimeError, /input/)
  end
end
