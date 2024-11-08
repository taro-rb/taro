Taro::Rails::ResponseValidator = Struct.new(:controller, :render_kwargs) do
  attr_accessor :definition

  def initialize(controller:, render_kwargs:)
    super(controller:, render_kwargs:)
  end

  def call
    # if the response validation is disabled, do nothing
    return unless Taro.config.invalid_response_callback

    # If this endpoint has no schema at all, ignore it.
    validate_with_definition if find_definition
  end

  private

  def find_definition
    self.definition =
      Taro::Rails.definitions.dig(controller.class, controller.action_name.to_sym)
  end

  def validate_with_definition
    if !render_kwargs.key?(:json)
      report(*non_json_response_info)
    elsif (type = definition.returns[status])
      validate_with_type(type)
    else
      report(*incomplete_definition_info)
    end
  end

  def status
    status = render_kwargs[:status] || 200
    Taro::Rails::Definition.coerce_status_to_int(status)
  end

  def validate_with_type(type)
    value = render_kwargs[:json]
    if Taro.config.response_nesting && type.nesting
      unless value.is_a?(Hash) && value.key?(type.nesting)
        return report(*missing_nesting_info(value, type))
      end

      value = value[type.nesting]
    end
    validate_value_against_type(value, type)
  end

  def validate_value_against_type(value, type)
    type.new(value).coerce_response ||
      report("Response does not match response schema.", "Expected #{type}, got #{value.class}.")
  rescue Taro::Error => e
    report("Response does not match response schema.", e.inspect)
  rescue StandardError => e
    report("Unhandled error when trying to validate response.", "#{e.inspect} @ #{e.backtrace.first}")
  end

  def report(msg, details)
    prefix = "Response validation error in #{controller.class}##{controller.action_name}"
    callback = Taro.config.invalid_response_callback
    callback.call(*["#{prefix}: #{msg}", details].first(callback.arity))
  end

  def missing_nesting_info(value, type)
    [
      "Response does not match response schema.",
      "Expected response with key :#{type.nesting}, got #{value.inspect}"
    ]
  end

  def non_json_response_info
    [
      "Response is not JSON.",
      "#{self.class} currently only works with controller actions that render JSON.",
    ]
  end

  def incomplete_definition_info
    [
      "Response status not defined in response schema.",
      "Responded with status #{status} but the defined response schemas are: #{definition.returns.keys}",
    ]
  end
end
