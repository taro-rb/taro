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

  # :api, :accepts, :returns, :routes

  # paths:
  # /users:
  #   get:
  #     summary: Returns a list of users.
  #     description: Optional extended description in CommonMark or HTML.
  #     responses:
  #       "200": # status code
  #         description: A JSON array of user names
  #         content:
  #           application/json:
  #             schema:
  #               type: array
  #               items:
  #                 type: string

  def export_definitions(definitions)
    paths = definitions.map { |defi| export_definition(defi) }
  end

  def export_definition(definition)
    
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
