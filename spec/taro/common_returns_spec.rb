describe Taro::CommonReturns do
  it 'defines common returns on a class' do
    klass = Class.new
    described_class.define(klass, code: 200)
    described_class.define(klass, code: 404)
    expect(described_class.for(klass).map(&:code)).to eq([200, 404])
  end

  it 'is inherited' do
    klass = Class.new
    described_class.define(klass, code: 200)
    child = Class.new(klass)
    described_class.define(child, code: 404)
    expect(described_class.for(klass).map(&:code)).to eq([200])
    expect(described_class.for(child).map(&:code)).to eq([200, 404])
  end
end
