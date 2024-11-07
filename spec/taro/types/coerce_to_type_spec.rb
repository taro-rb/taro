describe Taro::Types::CoerceToType do
  it "returns Taro types as-is" do
    expect(described_class.call(S::StringType)).to eq S::StringType
  end

  it "returns derived types based on Hashes" do
    expect(described_class.call(page_of: 'String'))
      .to eq T::ObjectTypes::PageType.for(S::StringType)
  end

  %w[
    Boolean
    Date
    DateTime
    Float
    Integer
    String
    Time
    UUID
  ].each do |type|
    it "casts the String #{type} to a Taro type" do
      expect(described_class.call(type)).to be < Taro::Types::BaseType
    end
  end

  it 'raises for unsupported Classes' do
    expect do
      described_class.call(Object)
    end.to raise_error(Taro::ArgumentError, /Unsupported type/)
  end

  it 'raises for unsupported Hashes' do
    expect do
      described_class.call({})
    end.to raise_error(Taro::ArgumentError, /Unsupported type/)
  end

  it 'raises for unsupported Strings' do
    expect do
      described_class.call('baddy_boy')
    end.to raise_error(Taro::ArgumentError, /Unsupported type/)
  end

  it 'raises for unsupported objects' do
    expect do
      described_class.call(Object.new)
    end.to raise_error(Taro::ArgumentError, /Unsupported type/)
  end
end
