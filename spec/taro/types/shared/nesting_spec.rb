describe Taro::Types::Shared::Nesting do
  it 'can use a custom proc for nesting' do
    test_type = Class.new(T::ObjectType)
    test_type.nesting = ->(_type) { 'custom' }
    expect(test_type.nesting).to eq :custom
  end

  it 'can remove custom nesting' do
    test_type = Class.new(T::ObjectType)
    test_type.define_singleton_method(:name) { 'TestType' }
    test_type.nesting = 'custom'
    test_type.nesting = nil
    expect(test_type.nesting).to eq :test
  end

  it 'inherits custom nesting from parent types' do
    test_type = Class.new(T::ObjectType)
    test_type.nesting = 'custom'
    expect(Class.new(test_type).nesting).to eq :custom
  end
end
