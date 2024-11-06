describe Taro::Types::Shared::CustomFieldResolvers do
  let(:example) { Class.new.include(described_class) }

  it 'keeps track of methods defined directly on this class' do
    expect(example.custom_resolvers).to eq({})
    example.define_method(:foo) { 'bar' }
    expect(example.custom_resolvers).to eq(foo: true)
  end

  it 'inherits them to subclasses' do
    example.define_method(:foo) { 'bar' }
    subclass = Class.new(example)
    subclass.define_method(:baz) { 'qux' }
    expect(example.custom_resolvers).to eq(foo: true)
    expect(subclass.custom_resolvers).to eq(foo: true, baz: true)
  end

  it 'raises when trying to implement an #object resolver method' do
    expect do
      example.define_method(:object) { 'bar' }
    end.to raise_error(Taro::ArgumentError, /object/)
  end
end
