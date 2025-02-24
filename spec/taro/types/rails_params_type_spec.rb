describe Taro::Types::RailsParamsType do
  it '*always* ignores undeclared hash keys', config: { raise_for_undeclared_params: true } do
    expect(described_class.new({ foo: 1 }).coerce_input).to eq({})
  end
end
