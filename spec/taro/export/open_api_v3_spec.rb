require 'yaml'

describe Taro::Export::OpenAPIv3 do
  it 'handles Declarations' do
    stub_const('FailureType', Class.new(T::ObjectType) do
      field :message, type: 'String', null: true
      field :code, type: 'Integer', null: false
    end)

    declaration = Taro::Rails::Declaration.new(
      api: 'My description',
      accepts: 'String',
      returns: {
        200 => 'Integer',
        404 => 'FailureType',
      },
      routes: [Taro::Rails::NormalizedRoute.new(mock_user_route)],
    )

    result = subject.export_declarations([declaration])

    expect(result.to_yaml.gsub(/(^| +)\K:/, '')).to eq <<~YAML
      ---
      paths:
        "/users/{id}":
          get:
            description: My description
            responses:
              '200':
                content:
                  application/json:
                    schema:
                      type: integer
              '404':
                content:
                  application/json:
                    schema:
                      $ref: "#/components/schemas/Failure"
      components:
        schemas:
          Failure:
            type: object
            required:
            - code
            properties:
              message:
                type:
                - string
                - null
              code:
                type: integer
    YAML
  end

  it 'handles scalar fields' do
    field = F.new(type: S::StringType, name: 'foo', null: false)
    expect(subject.export_field(field)).to eq(type: :string)
  end

  it 'handles nullable scalar fields' do
    field = F.new(type: S::StringType, name: 'foo', null: true)
    expect(subject.export_field(field)).to eq(type: %i[string null])
  end

  it 'handles field defaults' do
    field = F.new(type: S::StringType, default: '!', name: 'foo', null: false)
    expect(subject.export_field(field)).to eq(type: :string, default: '!')
  end

  it 'handles field descriptions' do
    field = F.new(type: S::StringType, name: 'foo', null: false, description: 'bar')
    expect(subject.export_field(field)).to eq(type: :string, description: 'bar')
  end

  it 'handles fields with inline enums' do
    field = F.new(type: S::StringType, name: 'foo', null: false, enum: ['bar', 'baz'])
    expect(subject.export_field(field)).to eq(type: :string, enum: ['bar', 'baz'])
  end

  it 'handles object fields' do
    stub_const('ThingType', Class.new(T::ObjectType) do
      field :inner, type: 'String', null: false
    end)
    field = F.new(type: ThingType, name: 'foo', null: false)

    expect(subject.export_field(field))
      .to eq(:$ref => "#/components/schemas/Thing")

    expect(subject.components).to eq(
      schemas: {
        Thing: {
          type: :object,
          required: [:inner],
          properties: {
            inner: { type: :string }
          }
        }
      }
    )
  end

  it 'handles object fields with description' do
    stub_const('ThingType', Class.new(T::ObjectType) do
      field :inner, type: 'String', null: false
    end)
    field = F.new(type: ThingType, name: 'foo', null: false, description: 'bar')

    expect(subject.export_field(field)).to eq(
      description: 'bar',
      allOf: [:$ref => "#/components/schemas/Thing"]
    )

    expect(subject.components).to eq(
      schemas: {
        Thing: {
          type: :object,
          required: [:inner],
          properties: {
            inner: { type: :string }
          }
        }
      }
    )
  end

  it 'handles enum fields' do
    stub_const('MyEnumType', Class.new(T::EnumType) do
      value 'foo'
      value 'bar'
    end)
    field = F.new(type: MyEnumType, name: 'foo', null: false)

    expect(subject.export_field(field))
      .to eq(:$ref => "#/components/schemas/MyEnum")

    expect(subject.components).to eq(
      schemas: {
        MyEnum: {
          enum: ["foo", "bar"],
          type: :string
        }
      }
    )
  end

  it 'handles NoContentType' do
    stub_const('NoContentType', Class.new(T::ObjectTypes::NoContentType))

    expect(subject.extract_component_ref(NoContentType))
      .to eq(:$ref => "#/components/schemas/NoContent")

    expect(subject.components).to eq(
      schemas: {
        NoContent: {
          type: :object,
          properties: {}
        }
      }
    )
  end

  it 'raises for not implemented refs' do
    expect { subject.build_type_ref(Float) }.to raise_error(NotImplementedError)
  end
end
