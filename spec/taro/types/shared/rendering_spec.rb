describe Taro::Types::Shared::Rendering do
  it 'returns the result of coerce_response' do
    test_type = Class.new(T::BaseType) do
      def coerce_response
        object.class.name
      end
    end
    expect(test_type.render('foo')).to eq('String')
  end
end
