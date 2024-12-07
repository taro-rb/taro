class Taro::Route
  attr_reader :endpoint, :openapi_operation_id, :openapi_path, :verb

  def initialize(endpoint:, openapi_operation_id:, openapi_path:, verb:)
    @endpoint = validate_string(endpoint:)
    @openapi_operation_id = validate_string(openapi_operation_id:)
    @openapi_path = validate_string(openapi_path:)
    @verb = validate_string(verb:).downcase
  end

  def path_params
    openapi_path.scan(/{(\w+)}/).flatten.map(&:to_sym)
  end

  def can_have_request_body?
    %w[patch post put].include?(verb)
  end

  def inspect
    %(#<#{self.class} "#{verb} #{openapi_path}">)
  end
  alias to_s inspect

  private

  def validate_string(**kwarg)
    name, arg = kwarg.first
    return arg if arg.is_a?(String)

    raise(Taro::ArgumentError, "#{name} must be a String, got #{arg.class}")
  end
end
