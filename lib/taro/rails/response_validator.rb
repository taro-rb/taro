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
