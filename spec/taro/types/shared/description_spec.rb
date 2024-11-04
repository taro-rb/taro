describe Taro::Types::Shared::Description do
  it 'adds a description setter and getter' do
    obj = Object.new.extend(described_class)
    obj.description = 'hello'
    expect(obj.description).to eq 'hello'
  end
end
