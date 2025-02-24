describe Taro::Types::Shared::ObjectCoercion do
  describe '#coerce_input' do
    it 'can ignore undeclared hash keys', config: { raise_for_undeclared_params: false } do
      expect(T::ObjectType.new({ foo: 1 }).coerce_input).to eq({})
    end

    it 'can raise for undeclared hash keys', config: { raise_for_undeclared_params: true } do
      expect { T::ObjectType.new({ foo: 1 }).coerce_input }
        .to raise_error(Taro::InputError, /Undeclared params: foo/)
    end
  end

  describe '#coerce_response' do
    it 'raises instructive errors for nested fields' do
      stub_const('InnerType', Class.new(T::ObjectType) do
        field(:str_field, type: 'String', null: false)
      end)
      outer_type = stub_const('OuterType', Class.new(T::ObjectType) do
        field(:obj_field, type: 'InnerType', null: false)
      end)

      object = double(
        class: 'OuterRecord', obj_field: double(
          class: 'InnerRecord', str_field: 123
        )
      )

      expect do
        outer_type.new(object).coerce_response
      end.to raise_error Taro::ResponseError, <<~MSG.chomp
        Integer is not valid as StringType at `obj_field.str_field`: must be a String or Symbol
      MSG
    end
  end
end
