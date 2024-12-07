Taro::Rails::ResponseValidator = Struct.new(:controller, :declaration, :rendered) do
  def self.call(*args)
    new(*args).call
  end

  def call
    if declared_return_type.nil?
      fail_if_declaration_expected
    elsif declared_return_type < Taro::Types::NestedResponseType
      field = declared_return_type.nesting_field
      check(field.type, denest_rendered(field.name))
    else
      check(declared_return_type, rendered)
    end
  end

  def declared_return_type
    @declared_return_type ||= declaration.returns[controller.status]
  end

  # Rack, Rails and gems commonly trigger rendering of 400, 404, 500 etc.
  # Declaring these codes should be optional. Otherwise the api schema would get
  # bloated as there are no "global" return declarations in OpenAPI v3, and we'd
  # need to export all of these for every single endpoint. v4 might change this.
  # https://github.com/OAI/OpenAPI-Specification/issues/521
  def fail_if_declaration_expected
    controller.status.to_s.match?(/^[123]|422/) && fail_with(<<~MSG)
      No return type declared for this status.
    MSG
  end

  def fail_with(message)
    raise Taro::ResponseError, <<~MSG
      Response validation error for
      #{controller.class}##{controller.action_name}, code #{controller.status}":
      #{message}
    MSG
  end

  # support `returns :some_nesting, type: 'SomeType'`
  # used like `render json: { some_nesting: SomeType.render(some_object) }`
  def denest_rendered(nesting)
    rendered.is_a?(Hash) || fail_with("Expected Hash, got #{rendered.class}.")

    if rendered.key?(nesting)
      rendered[nesting]
    else
      fail_with "Expected key :#{nesting}, got: #{rendered.keys}."
    end
  end

  def check(type = declared_return_type, value = rendered)
    if type < Taro::Types::ScalarType
      check_scalar(type, value)
    elsif type < Taro::Types::ListType &&
          type.item_type < Taro::Types::ScalarType
      check_scalar_array(type, value)
    elsif type < Taro::Types::EnumType
      check_enum(type, value)
    else
      check_custom_type(type, value)
    end
  end

  # For scalar and enum types, we want to support e.g. `render json: 42`,
  # and not require using the type as in `BeautifulNumbersEnum.render(42)`.
  def check_scalar(type, value)
    case type.openapi_type
    when :integer, :number then value.is_a?(Numeric)
    when :string           then value.is_a?(String) || value.is_a?(Symbol)
    when :boolean          then [true, false].include?(value)
    end || fail_with("Expected a #{type.openapi_type}, got: #{value.class}.")
  end

  def check_scalar_array(type, value)
    value.is_a?(Array) || fail_with('Expected an Array.')
    value.empty? || check_scalar(type.item_type, value.first)
  end

  def check_enum(type, value)
    # coercion checks non-emptyness + enum match
    type.new(value).coerce_response
  rescue Taro::Error => e
    fail_with(e.message)
  end

  # For complex/object types, we ensure conformance by checking whether
  # the type was used for rendering. This has performance benefits compared
  # to going over the structure a second time.
  def check_custom_type(type, value)
    # Ignore types without a specified structure.
    return if type <= Taro::Types::ObjectTypes::FreeFormType
    return if type <= Taro::Types::ObjectTypes::NoContentType

    strict_check_custom_type(type, value)
  end

  def strict_check_custom_type(type, value)
    used_type, rendered_object_id = type.last_render
    used_type&.<=(type) || fail_with(<<~MSG)
      Expected to use #{type}.render, but the last type rendered
      was: #{used_type || 'no type'}.
    MSG

    rendered_object_id == value.__id__ || fail_with(<<~MSG)
      #{type}.render was called, but the result
      of this call was not used in the response.
    MSG
  end
end
