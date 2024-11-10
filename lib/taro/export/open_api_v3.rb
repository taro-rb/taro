class Taro::Export::OpenAPIv3 # rubocop:disable Metrics/ClassLength
  attr_reader :schemas

  def initialize
    @schemas = {}
  end

  # TODO:
  # - use json-schema gem to validate overall result against OpenAPIv3 schema
  def call(declarations:, title: 'Taro-based API', version: '1.0')
    result = { openapi: '3.1.0', info: { title:, version: }, paths: {} }
    declarations.each do |declaration|
      declaration.routes.each do |route|
        result[:paths][route.openapi_path] = export_route(route, declaration)
      end
    end
    result.merge(components: { schemas: })
  end

  def export_route(route, declaration)
    {
      route.verb.to_sym => {
        description: declaration.api,
        parameters: path_parameters(declaration, route),
        requestBody: request_body(declaration, route),
        responses: responses(declaration),
      }.compact,
    }
  end

  def path_parameters(declaration, route) # rubocop:disable Metrics/MethodLength
    route.path_params.map do |param_name|
      param_field = declaration.params.fields[param_name] || raise(<<~MSG)
        Declaration missing for path param #{param_name} of route #{route.endpoint}
      MSG

      {
        name: param_field.name,
        in: 'path',
        description: param_field.description,
        required: !param_field.null,
        schema: { type: param_field.openapi_type },
      }.compact
    end
  end

  def request_body(declaration, route)
    params = declaration.params
    body_param_fields = params.fields.reject do |name, _field|
      route.path_params.include?(name)
    end
    return unless body_param_fields.any?

    body_input_type = Class.new(params)
    body_input_type.fields.replace(body_param_fields)
    body_input_type.openapi_name = params.openapi_name

    ref = extract_component_ref(body_input_type)
    { content: { 'application/json': { schema: ref } } }
  end

  def responses(declaration)
    declaration.returns.to_h do |code, type|
      [
        code.to_s,
        {
          description: declaration.return_descriptions[code],
          content: { 'application/json': { schema: export_type(type) } },
        }
      ]
    end
  end

  def export_type(type)
    if type < Taro::Types::ScalarType
      { type: type.openapi_type }
    else
      extract_component_ref(type)
    end
  end

  def export_field(field)
    if field.type < Taro::Types::ScalarType
      export_scalar_field(field)
    else
      export_complex_field_ref(field)
    end
  end

  def export_scalar_field(field)
    base = { type: field.openapi_type }
    base[:description] = field.description if field.description
    base[:default] = field.default if field.default_specified?
    base[:enum] = field.enum if field.enum
    base
  end

  def export_complex_field_ref(field)
    ref = extract_component_ref(field.type)
    if field.description || field.null
      # RE description: https://github.com/OAI/OpenAPI-Specification/issues/2033
      # RE nullable: https://stackoverflow.com/a/70658334
      nullable = true if field.null
      { description: field.description, nullable:, allOf: [ref] }.compact
    else
      ref
    end
  end

  def extract_component_ref(type)
    assert_unique_openapi_name(type)
    schemas[type.openapi_name.to_sym] ||= type_details(type)
    { '$ref': "#/components/schemas/#{type.openapi_name}" }
  end

  def type_details(type)
    if type.respond_to?(:fields) # InputType or ObjectType
      object_type_details(type)
    elsif type < Taro::Types::EnumType
      enum_type_details(type)
    elsif type < Taro::Types::ListType
      list_type_details(type)
    else
      raise NotImplementedError, "Unsupported type: #{type}"
    end
  end

  def object_type_details(type)
    required = type.fields.values.reject(&:null).map(&:name)
    {
      type: type.openapi_type,
      description: type.description,
      required: (required if required.any?),
      properties: type.fields.to_h { |name, f| [name, export_field(f)] },
    }.compact
  end

  def enum_type_details(enum)
    {
      type: enum.item_type.openapi_type,
      description: enum.description,
      enum: enum.values,
    }.compact
  end

  def list_type_details(list)
    {
      type: 'array',
      description: list.description,
      items: export_type(list.item_type),
    }.compact
  end

  def assert_unique_openapi_name(type)
    @name_to_type_map ||= {}
    if (prev = @name_to_type_map[type.openapi_name]) && type != prev
      raise("Duplicate openapi_name \"#{type.openapi_name}\" for types #{prev} and #{type}")
    else
      @name_to_type_map[type.openapi_name] = type
    end
  end
end
