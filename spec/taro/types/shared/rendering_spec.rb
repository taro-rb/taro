describe Taro::Types::Shared::Rendering do
  it 'nests the result by default' do
    test_type = Class.new(T::ObjectType)
    test_type.define_singleton_method(:name) { 'TestType' }
    test_type.field :name, type: 'String', null: true
    expect(test_type.render(name: 'Jane')).to eq(test: { name: 'Jane' })
  end

  it 'can nest the result in a custom key' do
    test_type = Class.new(T::ObjectType)
    test_type.nesting = 'custom'
    test_type.field :name, type: 'String', null: true
    expect(test_type.render(name: 'Jane')).to eq(custom: { name: 'Jane' })
  end

  it 'works if nesting is disabled', config: { response_nesting: false } do
    test_type = Class.new(T::ObjectType)
    test_type.field :name, type: 'String', null: true
    expect(test_type.render(name: 'Jane')).to eq(name: 'Jane')
  end
end
