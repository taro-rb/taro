Taro::Rails::ResponseValidator = Struct.new(:controller, :declaration, :rendered) do
  def self.call(*args)
    new(*args).call
  end

  def call
    if declared_return_type < Taro::Types::ScalarType
      check_scalar
    elsif declared_return_type < Taro::Types::ListType &&
          declared_return_type.item_type < Taro::Types::ScalarType
      check_scalar_array
    elsif declared_return_type < Taro::Types::EnumType
      check_enum
    else
      check_custom_type
    end
  end

  def declared_return_type
    @declared_return_type ||= begin
      return_type = declaration.returns[controller.status] ||
                    fail_with('No return type declared for this status.')
      nesting ? return_type.fields.fetch(nesting).type : return_type
    end
  end

  def fail_with(message)
    raise Taro::ResponseError, <<~MSG
      Response validation error for
      #{controller.class}##{controller.action_name}, code #{controller.status}":
      #{message}
    MSG
  end

  # support `returns :some_nesting, type: 'SomeType'` (ad-hoc return type)
  def nesting
    @nesting ||= declaration.return_nestings[controller.status]
  end

  def denest_rendered
    assert_rendered_is_a_hash

    if rendered.key?(nesting)
      rendered[nesting]
    elsif rendered.key?(nesting.to_s)
      rendered[nesting.to_s]
    else
      fail_with_nesting_error
    end
  end

  def assert_rendered_is_a_hash
    rendered.is_a?(Hash) || fail_with("Expected Hash, got #{rendered.class}.")
  end

  def fail_with_nesting_error
    fail_with "Expected key :#{nesting}, got: #{rendered.keys}."
  end

  # For scalar and enum types, we want to support e.g. `render json: 42`,
  # and not require using the type as in `BeautifulNumbersEnum.render(42)`.
  def check_scalar(type = declared_return_type, value = subject)
    case type.openapi_type
    when :integer, :number then value.is_a?(Numeric)
    when :string           then value.is_a?(String) || value.is_a?(Symbol)
    when :boolean          then [true, false].include?(value)
    end || fail_with("Expected a #{type.openapi_type}, got: #{value.class}.")
  end

  def subject
    @subject ||= nesting ? denest_rendered : rendered
  end

  def check_scalar_array
    subject.is_a?(Array) || fail_with('Expected an Array.')
    subject.empty? || check_scalar(declared_return_type.item_type, subject.first)
  end

  def check_enum
    # coercion checks non-emptyness + enum match
    declared_return_type.new(subject).coerce_response
  rescue Taro::Error => e
    fail_with(e.message)
  end

  # For complex/object types, we ensure conformance by checking whether
  # the type was used for rendering. This has performance benefits compared
  # to going over the structure a second time.
  def check_custom_type
    # Ignore types without a specified structure.
    return if declared_return_type <= Taro::Types::ObjectTypes::FreeFormType
    return if declared_return_type <= Taro::Types::ObjectTypes::NoContentType

    strict_check_custom_type
  end

  def strict_check_custom_type
    used_type, rendered_object_id = declared_return_type.last_render
    used_type&.<=(declared_return_type) || fail_with(<<~MSG)
      Expected to use #{declared_return_type}.render, but the last type rendered
      was: #{used_type || 'no type'}.
    MSG

    rendered_object_id == subject.__id__ || fail_with(<<~MSG)
      #{declared_return_type}.render was called, but the result
      of this call was not used in the response.
    MSG
  end
end
