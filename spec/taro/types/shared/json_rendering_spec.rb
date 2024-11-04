describe Taro::Types::Shared::JSONRendering do
  it 'nests the result by default' do
    test_type = Class.new(T::ObjectType)
    test_type.define_singleton_method(:name) { 'TestType' }
    test_type.field(:name) { [String, null: true] }
    expect(test_type.render(name: 'Jane')).to eq('test' => { name: 'Jane' })
  end

  it 'can nest the result in a custom key' do
    test_type = Class.new(T::ObjectType)
    test_type.nesting = 'custom'
    test_type.field(:name) { [String, null: true] }
    expect(test_type.render(name: 'Jane')).to eq('custom' => { name: 'Jane' })
  end

  it 'works if nesting is disabled' do
    orig = Taro.config.response_nesting
    Taro.config.response_nesting = false

    test_type = Class.new(T::ObjectType)
    test_type.field(:name) { [String, null: true] }
    expect(test_type.render(name: 'Jane')).to eq(name: 'Jane')
  ensure
    Taro.config.response_nesting = orig
  end
end
