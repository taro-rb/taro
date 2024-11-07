describe Taro::Types::CoerceToType do
  it "returns Taro types as-is" do
    expect(described_class.call(S::StringType)).to eq S::StringType
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

  it 'raises for unsupported types' do
    expect do
      described_class.call(Object)
    end.to raise_error(Taro::ArgumentError, /Unsupported type/)
  end
end
