describe Taro::Types::Shared::Caching do
  it 'can set cache_key to a Proc with arity 1' do
    type = Class.new(Taro::Types::BaseType)
    type.cache_key = ->(object) { object }
    expect(type.cache_key).to be_a(Proc)
  end

  it 'can set cache_key to a Hash' do
    type = Class.new(Taro::Types::BaseType)
    type.cache_key = {}
    expect(type.cache_key).to eq({})
  end

  it 'can set cache_key to nil' do
    type = Class.new(Taro::Types::BaseType)
    type.cache_key = nil
    expect(type.cache_key).to be_nil
  end

  it 'fails for procs with arity != 1' do
    type = Class.new(Taro::Types::BaseType)
    expect { type.cache_key = -> {} }.to raise_error(Taro::ArgumentError)
  end

  it 'fails for strings' do
    type = Class.new(Taro::Types::BaseType)
    expect { type.cache_key = 'foo' }.to raise_error(Taro::ArgumentError)
  end

  it 'allows string keys for ::with_cache' do
    type = Class.new(Taro::Types::BaseType)
    expect(type.with_cache(cache_key: 'foo').cache_key).to be_a(Proc)
  end

  it 'supports proc keys for ::with_cache' do
    type = Class.new(Taro::Types::BaseType)
    cache_key = ->(_) { 'foo' }
    expect(type.with_cache(cache_key:).cache_key).to eq cache_key
  end

  it 'raises when ::with_cache is followed by derivations' do
    type = Class.new(Taro::Types::BaseType)
    expect { type.array.with_cache(cache_key: ->(_) { 'foo' }) }
      .to raise_error(Taro::ArgumentError, /Cannot derive/)
  end

  it 'applies to scalar type rendering' do
    type = Class.new(S::StringType)
    type.cache_key = ->(_) { 42 }
    allow(DUMMY_CACHE)
      .to receive(:fetch).with(42, expires_in: nil)
      .and_return('cached string')

    expect(type.render('does not matter')).to eq 'cached string'
  end

  it 'applies to array type rendering' do
    type = S::StringType.array
    type.cache_key = ->(_) { 42 }
    allow(DUMMY_CACHE)
      .to receive(:fetch).with(42, expires_in: nil)
      .and_return(['cached array'])

    expect(type.render(['does not matter'])).to eq ['cached array']
  end

  it 'applies to object type rendering' do
    type = Class.new(T::ObjectType)
    type.field(:my_field, type: 'String', null: false)
    type.cache_key = ->(_) { 42 }
    allow(DUMMY_CACHE)
      .to receive(:fetch).with(42, expires_in: nil)
      .and_return(my_field: 'cached value')

    expect(type.render('does not matter')).to eq(my_field: 'cached value')
  end
end
