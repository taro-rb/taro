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
    expect(T::BaseType.used_in_response).to eq(test_type)
  end
end
