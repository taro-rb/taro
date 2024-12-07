describe Taro::Export::OpenAPIv3 do
  it 'handles Declarations' do
    stub_const('FailureType', Class.new(T::ObjectType) do
      self.deprecated = true
      field :message, type: 'String', null: true, deprecated: true
      field :code, type: 'Integer', null: false
    end)

    update_decl = Taro::Rails::Declaration.new
    update_decl.add_info 'My endpoint description'
    update_decl.add_param :id, type: 'Integer', enum: [1, 2, 3], null: false, desc: 'The ID'
    update_decl.add_param :foo, type: 'String', null: true, deprecated: true
    update_decl.add_return type: 'Integer', code: 200, desc: 'okay'
    update_decl.add_return :errors, array_of: 'FailureType', code: 422, null: false, desc: 'bad'
    update_decl.routes = [Taro::Rails::NormalizedRoute.new(mock_user_route)]

    stub_const('MyEnumType', Class.new(T::EnumType) do
      value 4
      value 5
    end)

    delete_decl = Taro::Rails::Declaration.new
    delete_decl.add_info 'My endpoint description for DELETE'
    delete_decl.add_param :id, type: 'MyEnumType', null: false
    delete_decl.add_return type: 'Integer', code: 200, desc: 'okay'
    delete_decl.routes = [Taro::Rails::NormalizedRoute.new(mock_user_route(verb: 'DELETE', action: 'destroy'))]

    show_decl = Taro::Rails::Declaration.new
    show_decl.add_info 'My endpoint description for GET'
    show_decl.add_param :id, type: 'Integer', null: false
    show_decl.add_param :show_details, type: 'Boolean', null: false
    show_decl.add_return type: 'UUID', code: 200, desc: 'okay'
    show_decl.routes = [Taro::Rails::NormalizedRoute.new(mock_user_route(verb: 'GET', action: 'show'))]

    result = described_class.call(declarations: [update_decl, delete_decl, show_decl])

    expect(result.to_yaml).to eq <<~YAML
      ---
      openapi: 3.1.0
      info:
        title: Taro-based API
        version: '1.0'
      paths:
        "/users/{id}":
          delete:
            summary: My endpoint description for DELETE
            operationId: delete_destroy_users
            parameters:
            - name: id
              required: true
              schema:
                "$ref": "#/components/schemas/MyEnum"
              in: path
            responses:
              '200':
                description: okay
                content:
                  application/json:
                    schema:
                      type: integer
          get:
            summary: My endpoint description for GET
            operationId: get_show_users
            parameters:
            - name: id
              required: true
              schema:
                type: integer
              in: path
            - name: show_details
              required: true
              schema:
                type: boolean
              in: query
            responses:
              '200':
                description: okay
                content:
                  application/json:
                    schema:
                      "$ref": "#/components/schemas/UUIDv4"
          put:
            summary: My endpoint description
            operationId: put_update_users
            parameters:
            - name: id
              description: The ID
              required: true
              schema:
                type: integer
                enum:
                - 1
                - 2
                - 3
              in: path
            requestBody:
              content:
                application/json:
                  schema:
                    "$ref": "#/components/schemas/put_update_users_Input"
            responses:
              '200':
                description: okay
                content:
                  application/json:
                    schema:
                      type: integer
              '422':
                description: bad
                content:
                  application/json:
                    schema:
                      "$ref": "#/components/schemas/Failure_List_in_errors_Response"
      components:
        schemas:
          Failure:
            type: object
            deprecated: true
            required:
            - code
            properties:
              message:
                oneOf:
                - type: string
                - type: 'null'
                deprecated: true
              code:
                type: integer
          Failure_List:
            type: array
            items:
              "$ref": "#/components/schemas/Failure"
          Failure_List_in_errors_Response:
            type: object
            required:
            - errors
            properties:
              errors:
                "$ref": "#/components/schemas/Failure_List"
          MyEnum:
            type: integer
            enum:
            - 4
            - 5
          UUIDv4:
            type: string
            description: A UUID v4 string
            pattern: "^[0-9a-fA-F]{8}-?(?:[0-9a-fA-F]{4}-?){3}[0-9a-fA-F]{12}$"
          put_update_users_Input:
            type: object
            properties:
              foo:
                oneOf:
                - type: string
                - type: 'null'
                deprecated: true
    YAML
  end

  it 'can be exported as json' do
    expect(described_class.call(declarations: []).to_json).to eq(<<~JSON.chomp)
      {
        "openapi": "3.1.0",
        "info": {
          "title": "Taro-based API",
          "version": "1.0"
        }
      }
    JSON
  end

  it 'does not render requestBody if there are no body params' do
    declaration = Taro::Rails::Declaration.new
    declaration.add_param :id, type: 'Integer', null: false
    declaration.routes = [Taro::Rails::NormalizedRoute.new(mock_user_route)]

    result = described_class.call(declarations: [declaration]).result
    expect(result[:paths].values.first[:put]).not_to have_key(:requestBody)
  end

  it 'handles scalar fields' do
    field = F.new(type: S::StringType, name: 'foo', null: false)
    expect(subject.export_field(field)).to eq(type: :string)
  end

  it 'handles nullable scalar fields' do
    field = F.new(type: S::StringType, name: 'foo', null: true)
    expect(subject.export_field(field)).to eq(oneOf: [{ type: :string }, { type: 'null' }])
  end

  it 'handles field defaults' do
    field = F.new(type: S::StringType, default: '!', name: 'foo', null: false)
    expect(subject.export_field(field)).to eq(type: :string, default: '!')
  end

  it 'handles field descriptions' do
    field = F.new(type: S::StringType, name: 'foo', null: false, desc: 'bar')
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

    expect(subject.schemas).to eq(
      Thing: {
        type: :object,
        required: [:inner],
        properties: {
          inner: { type: :string }
        }
      }
    )
  end

  it 'handles object fields with description' do
    stub_const('ThingType', Class.new(T::ObjectType) do
      field :inner, type: 'String', null: false
    end)
    field = F.new(type: ThingType, name: 'foo', null: false, desc: 'bar')

    expect(subject.export_field(field)).to eq(
      description: 'bar',
      allOf: [:$ref => "#/components/schemas/Thing"]
    )
  end

  it 'handles nullable object fields with description' do
    stub_const('ThingType', Class.new(T::ObjectType) do
      field :inner, type: 'String', null: false
    end)
    field = F.new(type: ThingType, name: 'foo', null: true, desc: 'bar')

    expect(subject.export_field(field)).to eq(
      description: 'bar',
      oneOf: [{ :$ref => "#/components/schemas/Thing" }, { type: 'null' }],
    )
  end

  it 'handles nullable object fields without description' do
    stub_const('ThingType', Class.new(T::ObjectType) do
      field :inner, type: 'String', null: false
    end)
    field = F.new(type: ThingType, name: 'foo', null: true)

    expect(subject.export_field(field)).to eq(
      oneOf: [{ :$ref => "#/components/schemas/Thing" }, { type: 'null' }],
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

    expect(subject.schemas).to eq(
      MyEnum: {
        enum: ["foo", "bar"],
        type: :string
      }
    )
  end

  it 'handles NoContentType' do
    stub_const('NoContentType', Class.new(T::ObjectTypes::NoContentType))

    expect(subject.extract_component_ref(NoContentType))
      .to eq(:$ref => "#/components/schemas/NoContent")

    expect(subject.schemas).to eq(
      NoContent: {
        type: :object,
        properties: {},
      }
    )
  end

  it 'handles FreeFormType' do
    stub_const('FreeFormType', Class.new(T::ObjectTypes::FreeFormType))

    expect(subject.extract_component_ref(FreeFormType))
      .to eq(:$ref => "#/components/schemas/FreeForm")

    expect(subject.schemas).to eq(
      FreeForm: {
        type: :object,
        properties: {},
        additionalProperties: true,
      }
    )
  end

  it 'handles PageType' do
    expect(subject.extract_component_ref(S::StringType.page))
      .to eq(:$ref => "#/components/schemas/string_Page")

    expect(subject.schemas).to match(
      string_Page: {
        type: :object,
        properties:
        {
          page: { :$ref => "#/components/schemas/string_List" },
          page_info: { :$ref => "#/components/schemas/PageInfo" },
        },
        required: [:page, :page_info],
      },
      string_List: {
        type: 'array',
        items: { type: :string },
      },
      PageInfo: instance_of(Hash),
    )
  end

  it 'always marks path params as required' do
    declaration = Taro::Rails::Declaration.new
    declaration.add_param :id, type: 'Integer', null: true # incorrect null
    route = Taro::Rails::NormalizedRoute.new(mock_user_route)
    path_params = subject.path_parameters(declaration, route)
    expect(path_params.size).to eq 1
    expect(path_params.first).to include(required: true)
  end

  it 'uses inline request body for polymorphic routes' do
    stub_const('InputType', Class.new(T::InputType) do
      field :inner, type: 'String', null: false
    end)
    expect(subject.request_body_schema(InputType, use_refs: false)).to eq(
      properties: { inner: { type: :string } },
      required: [:inner],
      type: :object,
    )
  end

  it 'raises if two types have the same openapi_name' do
    stub_const('T1', Class.new(T::ObjectType) { self.openapi_name = 'foo' })
    stub_const('T2', Class.new(T::ObjectType) { self.openapi_name = 'foo' })
    subject.extract_component_ref(T1)
    expect { subject.extract_component_ref(T2) }
      .to raise_error('Duplicate openapi_name "foo" for types T1 and T2')
  end

  it 'does not raises if two NestedResponseTypes have the same openapi_name' do
    # there can be duplicates of these, but the same name means an identical structure
    stub_const('T1', Class.new(T::NestedResponseType) { self.openapi_name = 'foo' })
    stub_const('T2', Class.new(T::NestedResponseType) { self.openapi_name = 'foo' })
    subject.extract_component_ref(T1)
    expect { subject.extract_component_ref(T2) }.not_to raise_error
  end

  it 'raises for not implemented types' do
    expect { subject.type_details(Float) }.to raise_error(NotImplementedError)
  end
end
