describe Taro::Types::Shared::Deprecation do
  it 'adds a deprecated setter and getter' do
    obj = Object.new.extend(described_class)
    obj.deprecated = 'hello'
    expect(obj.deprecated).to eq true
    obj.deprecated = false
    expect(obj.deprecated).to eq nil
  end
end
