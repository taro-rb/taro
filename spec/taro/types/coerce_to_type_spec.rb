describe Taro::Types::CoerceToType do
  it "returns Taro types as-is" do
    expect(described_class.call(S::StringType)).to eq S::StringType
  end

  [
    ::Date,
    ::DateTime,
    ::Float,
    ::Integer,
    ::String,
    ::Time,
  ].each do |type|
    it "casts the Ruby class #{type} to a Taro type" do
      expect(described_class.call(type)).to be < Taro::Types::BaseType
    end
  end

  it 'casts arrays to list types' do
    expect(described_class.call([String])).to be < Taro::Types::ListType
  end

  it 'raises for unsupported types' do
    expect do
      described_class.call(Object)
    end.to raise_error(Taro::ArgumentError, /Unsupported type/)
  end
end
