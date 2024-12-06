class Taro::Export::OpenAPIv3 < Taro::Export::Base # rubocop:disable Metrics/ClassLength
  attr_reader :schemas

  def initialize
    super
    @schemas = {}
  end

  # TODO:
  # - use json-schema gem to validate overall result against OpenAPIv3 schema
  def call(declarations:, title:, version:)
    @result = { openapi: '3.1.0', info: { title:, version: } }
    paths = export_paths(declarations)
    @result[:paths] = paths.sort.to_h if paths.any?
    @result[:components] = { schemas: schemas.sort.to_h } if schemas.any?
    self
  end

  def export_paths(declarations)
    declarations.sort.each_with_object({}) do |declaration, paths|
      declaration.routes.each do |route|
        paths[route.openapi_path] ||= {}
        paths[route.openapi_path].merge! export_route(route, declaration)
      end
    end
  end

  def export_route(route, declaration)
    {
      route.verb.to_sym => {
        description: declaration.desc,
        summary: declaration.summary,
        tags: declaration.tags,
        operationId: route.openapi_operation_id,
        parameters: route_parameters(declaration, route),
        requestBody: request_body(declaration, route),
        responses: responses(declaration, route),
      }.compact,
    }
  end

  def route_parameters(declaration, route)
    path_parameters(declaration, route) + query_parameters(declaration, route)
  end

  def path_parameters(declaration, route)
    route.path_params.map do |param_name|
      param_field = declaration.params.fields[param_name] || raise(<<~MSG)
        Declaration missing for path param #{param_name} of route #{route.endpoint}
      MSG

      # path params are always required in rails
      export_parameter(param_field).merge(in: 'path', required: true)
    end
  end

  def query_parameters(declaration, route)
    return [] if route.can_have_request_body?

    declaration.params.fields.filter_map do |name, param_field|
      next if route.path_params.include?(name)

      export_parameter(param_field).merge(in: 'query')
    end
  end

  def export_parameter(field)
    validate_path_or_query_parameter(field)

    {
      name: field.name,
      deprecated: field.deprecated,
      description: field.desc,
      required: !field.null,
      schema: export_field(field).except(:deprecated, :description),
    }.compact
  end

  def validate_path_or_query_parameter(field)
    [:array, :object].include?(field.type.openapi_type) &&
      raise("Unexpected object as path/query param #{field.name}: #{field.type}")
  end

  def request_body(declaration, route)
    return unless route.can_have_request_body?

    params = declaration.params
    body_param_fields = params.fields.reject do |name, _field|
      route.path_params.include?(name)
    end
    return unless body_param_fields.any?

    body_input_type = Class.new(params)
    body_input_type.fields.replace(body_param_fields)
    body_input_type.openapi_name = "#{route.openapi_operation_id}_Input"

    # For polymorphic routes (more than one for the same declaration),
    # we can't use refs because their request body might differ:
    # Different params might be in the path vs. in the request body.
    use_refs = !declaration.polymorphic_route?
    schema = request_body_schema(body_input_type, use_refs:)
    { content: { 'application/json': { schema: } } }
  end

  def request_body_schema(type, use_refs:)
    if use_refs
      extract_component_ref(type)
    else
      type_details(type)
    end
  end

  def responses(declaration, route)
    name_anonymous_return_types(declaration, route)

    declaration.returns.sort.to_h do |code, type|
      [
        code.to_s,
        {
          # response desc is required in openapi 3 – fall back to status code
          description: declaration.return_descriptions[code] || type.desc || code.to_s,
          content: { 'application/json': { schema: export_type(type) } },
        }
      ]
    end
  end

  def name_anonymous_return_types(declaration, route)
    declaration.returns.each do |code, type|
      next if type.openapi_name?

      type.openapi_name = "#{route.openapi_operation_id}_#{code}_Response"
    end
  end

  def export_type(type)
    if type < Taro::Types::ScalarType && !custom_scalar_type?(type)
      { type: type.openapi_type }
    else
      extract_component_ref(type)
    end
  end

  def custom_scalar_type?(type)
    type < Taro::Types::ScalarType && (type.openapi_pattern || type.deprecated)
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
    # Using oneOf seems more correct than an array of types
    # as it puts props like format together with the main type.
    # https://github.com/OAI/OpenAPI-Specification/issues/3148
    base = { oneOf: [base, { type: 'null' }] } if field.null
    base.merge(field_metadata(field))
  end

  def export_complex_field_ref(field)
    ref = extract_component_ref(field.type)
    return ref if field_metadata(field).empty? && !field.null

    if field.null
      # RE nullable: https://stackoverflow.com/a/70658334
      { oneOf: [ref, { type: 'null' }] }
    else # i.e. with metadata such as description or deprecated
      # https://github.com/OAI/OpenAPI-Specification/issues/2033
      { allOf: [ref] }
    end.merge(field_metadata(field))
  end

  def field_metadata(field)
    meta = {}
    meta[:description] = field.desc if field.desc
    meta[:deprecated] = field.deprecated unless field.deprecated.nil?
    meta[:default] = field.default if field.default_specified?
    meta[:enum] = field.enum if field.enum
    meta
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
    elsif custom_scalar_type?(type)
      custom_scalar_type_details(type)
    else
      raise NotImplementedError, "Unsupported type: #{type}"
    end
  end

  def object_type_details(type)
    required = type.fields.values.reject(&:null).map(&:name)
    {
      type: type.openapi_type,
      deprecated: type.deprecated,
      description: type.desc,
      required: (required if required.any?),
      properties: type.fields.to_h { |name, f| [name, export_field(f)] },
      additionalProperties: (true if type.additional_properties?),
    }.compact
  end

  def enum_type_details(enum)
    {
      type: enum.item_type.openapi_type,
      deprecated: enum.deprecated,
      description: enum.desc,
      enum: enum.values,
    }.compact
  end

  def list_type_details(list)
    {
      type: 'array',
      deprecated: list.deprecated,
      description: list.desc,
      items: export_type(list.item_type),
    }.compact
  end

  def custom_scalar_type_details(scalar)
    {
      type: scalar.openapi_type,
      deprecated: scalar.deprecated,
      description: scalar.desc,
      pattern: scalar.openapi_pattern,
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
