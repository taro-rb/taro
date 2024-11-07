class Taro::Export::OpenAPIv3
  attr_reader :components

  # TODO:
  # - accept Taro::Rails.definitions as an argument
  # - get routes (#openapi_paths), params, status codes, responses etc. from each Definition
  # - use methods below to render their details
  # - support list/array type
  # - use json-schema gem to validate overall result against OpenAPIv3 schema
  def initialize
    @components = {}
  end

  def export_definitions(definitions)
    definitions.each_with_object({ paths: {} }) do |definition, result|
      definition.routes.each do |route|
        result[:paths][openapi_path(route)] = export_route(route, definition)
      end
    end.merge(components:)
  end

  def export_route(route, definition)
    {
      # TODO: unify with verb handling in Definition
      route.verb.scan(/\w+/).sort.last.downcase => {
        description: definition.api,
        responses: export_responses(definition.returns),
      }.compact,
    }
  end

  def openapi_path(route)
    route.path.spec.to_s.gsub(/:(\w+)/, '{\1}').gsub('(.:format)', '')
  end

  def export_responses(returns)
    returns.to_h do |code, type|
      [
        code.to_s,
        { content: { :'application/json' => { schema: export_type(type) } } }
      ]
    end
  end

  # TODO: array, enum
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
      export_complex_field(field)
    end
  end

  def export_scalar_field(field)
    base = { type: field.openapi_type }
    base[:description] = field.description if field.description
    base[:default] = field.default if field.default_specified?
    base[:enum] = field.enum if field.enum
    base
  end

  def export_complex_field(field)
    ref = extract_component_ref(field.type)
    if field.description
      # https://github.com/OAI/OpenAPI-Specification/issues/2033
      { description: field.description, allOf: [ref] }
    else
      ref
    end
  end

  def extract_component_ref(type)
    components[:schemas] ||= {}
    components[:schemas][type.nesting.to_sym] ||= build_type_ref(type)
    { :'$ref' => "#/components/schemas/#{type.nesting}" }
  end

  def build_type_ref(type)
    if type.respond_to?(:fields) # InputType or ObjectType
      build_object_type_ref(type)
    elsif type < Taro::Types::EnumType
      build_enum_type_ref(type)
    else
      raise NotImplementedError, "Unsupported type: #{type}"
    end
  end

  def build_object_type_ref(type)
    {
      type: type.openapi_type,
      description: type.description,
      required: type.fields.values.reject(&:null).map(&:name),
      properties: type.fields.to_h { |name, f| [name, export_field(f)] },
    }.compact
  end

  def build_enum_type_ref(enum)
    {
      type: enum.item_type.openapi_type,
      description: enum.description,
      enum: enum.values,
    }.compact
  end
end
