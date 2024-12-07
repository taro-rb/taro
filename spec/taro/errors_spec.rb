describe Taro::Error do
  describe '#message' do
    it 'omits newlines from heredocs' do
      expect(described_class.new("foo\nbar\n").message).to eq('foo bar')
    end
  end
end

describe Taro::ValidationError do
  it 'raises an error when instantiated directly' do
    expect { described_class.new('message', nil, nil) }
      .to raise_error(RuntimeError, 'Abstract class')
  end
end
