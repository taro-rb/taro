describe Taro::Types::Shared::Description do
  it 'adds a desc setter and getter' do
    obj = Object.new.extend(described_class)
    obj.desc = 'hello'
    expect(obj.desc).to eq 'hello'
  end
end
