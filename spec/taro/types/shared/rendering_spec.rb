describe Taro::Types::Shared::Rendering do
  let(:test_type) do
    Class.new(T::BaseType) do
      def coerce_response
        object.class.name
      end
    end
  end

  it 'returns the result of coerce_response' do
    expect(test_type.render('foo')).to eq('String')
  end

  it 'keeps track of the type used for rendering' do
    test_type.render('foo')
    expect(T::BaseType.rendering).to eq(test_type)
  end

  it 'raises if called multiple times (DoubleRendering)' do
    test_type.render('foo')
    expect { test_type.render('foo') }.to raise_error(Taro::RuntimeError)
  end
end
