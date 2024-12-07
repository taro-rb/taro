describe Taro::Rails::ResponseValidator do
  let(:controller) { double(class: 'Foo', action_name: 'bar', status: 200) }
  let(:declaration) { Taro::Rails::Declaration.new }
  let(:err) { Taro::ResponseError }

  def test(arg)
    described_class.call(controller, declaration, arg)
  end

  it 'can pass' do
    declaration.add_return(code: 200, type: 'String')
    expect { test('str') }.not_to raise_error
  end

  it 'can pass for nested responses' do
    declaration.add_return(:nest, code: 200, type: 'String')
    expect { test(nest: 'str') }.not_to raise_error
  end

  it 'can pass for array responses' do
    declaration.add_return(code: 200, array_of: 'String')
    expect { test(['str']) }.not_to raise_error
  end

  it 'can pass for empty array responses' do
    declaration.add_return(code: 200, array_of: 'String')
    expect { test([]) }.not_to raise_error
  end

  it 'can pass for nested array responses' do
    declaration.add_return(:nest, code: 200, array_of: 'String')
    expect { test(nest: ['str']) }.not_to raise_error
  end

  it 'can pass for booleans' do
    declaration.add_return(code: 200, type: 'Boolean')
    expect { test(true) }.not_to raise_error
  end

  it 'can pass for numbers' do
    declaration.add_return(code: 200, type: 'Integer')
    expect { test(42) }.not_to raise_error
  end

  it 'can pass for symbols used as strings' do
    declaration.add_return(code: 200, type: 'String')
    expect { test(:str) }.not_to raise_error
  end

  it 'can pass for enum types' do
    stub_const('MyEnum', Class.new(T::EnumType))
    MyEnum.value 'str'
    declaration.add_return(code: 200, type: 'MyEnum')
    expect { test('str') }.not_to raise_error
  end

  it 'can pass for object types' do
    stub_const('MyObj', Class.new(T::ObjectType))
    MyObj.field(:bar, type: 'String', null: false)
    declaration.add_return(code: 200, type: 'MyObj')
    result = MyObj.render(bar: 'baz')

    expect { test(result) }.not_to raise_error
  end

  it 'can pass for FreeForm' do
    declaration.add_return(code: 200, type: 'FreeForm')
    expect { test(foo: 'bar') }.not_to raise_error
  end

  it 'can pass for NoContent' do
    declaration.add_return(code: 200, type: 'NoContent')
    expect { test({}) }.not_to raise_error
  end

  it 'fails when given nil' do
    declaration.add_return(code: 200, type: 'String')
    expect { test(nil) }.to raise_error(err, /Expected a string/)
  end

  it 'fails when given the wrong scalar' do
    declaration.add_return(code: 200, type: 'String')
    expect { test(42) }.to raise_error(err, /Expected a string/)
  end

  it 'fails when given the wrong scalar in an array' do
    declaration.add_return(code: 200, array_of: 'String')
    expect { test([42]) }.to raise_error(err, /Expected a string/)
  end

  it 'fails when given a non-array as an array' do
    declaration.add_return(code: 200, array_of: 'String')
    expect { test('str') }.to raise_error(err, /Expected an Array/)
  end

  it 'fails when not given the declared nesting' do
    declaration.add_return(:nest, code: 200, type: 'String')
    expect { test('str') }.to raise_error(err, /Expected Hash, got String/)
  end

  it 'fails when given a different than the declared nesting' do
    declaration.add_return(:nest, code: 200, type: 'String')
    expect { test(x: 'str') }.to raise_error(err, /Expected key :nest, got: \[:x\]/)
  end

  it 'fails when given the declared nesting with a string key' do
    declaration.add_return(:nest, code: 200, type: 'String')
    expect { test('nest' => 'str') }
      .to raise_error(err, /Expected key :nest, got: \["nest"\]/)
  end

  it 'fails for enum types if given a non-enum value' do
    stub_const('MyEnum', Class.new(T::EnumType))
    MyEnum.value 'str'
    declaration.add_return(code: 200, type: 'MyEnum')
    expect { test('OTHER') }.to raise_error(err, /must be "str"/)
  end

  it 'fails for object types if render was not called' do
    stub_const('MyObj', Class.new(T::ObjectType))
    MyObj.field(:bar, type: 'String', null: false)
    declaration.add_return(code: 200, type: 'MyObj')

    expect { test(bar: 'baz') }.to raise_error(err, /Expected to use MyObj.render/)
  end

  it 'fails for object types if render was called on another type' do
    stub_const('MyObj', Class.new(T::ObjectType))
    MyObj.field(:bar, type: 'String', null: false)
    declaration.add_return(code: 200, type: 'MyObj')
    S::StringType.render('baz')

    expect { test(bar: 'baz') }.to raise_error(err, /Expected to use MyObj.render/)
  end

  it 'fails for object types if the render result was not used' do
    stub_const('MyObj', Class.new(T::ObjectType))
    MyObj.field(:bar, type: 'String', null: false)
    declaration.add_return(code: 200, type: 'MyObj')
    _result = MyObj.render(bar: 'baz')

    expect { test(bar: 'baz') }.to raise_error(err, /not used in the response/)
  end

  it 'fails when given a non-standard openapi_type' do
    declaration.add_return(code: 200, type: 'String')
    allow(declaration.returns[200]).to receive(:openapi_type).and_return(:foo)
    expect { test('str') }.to raise_error(err, /Expected a foo/)
  end

  it 'fails when given a status for which no return type is declared' do
    declaration.add_return(code: 204, type: 'String')
    expect { test('str') }.to raise_error(err, /No return type declared for this status/)
  end
end
