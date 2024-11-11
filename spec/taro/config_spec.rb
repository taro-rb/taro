describe Taro::Config do
  it 'parse_params is true by default' do
    expect(Taro.config.parse_params).to eq(true)
  end
end
