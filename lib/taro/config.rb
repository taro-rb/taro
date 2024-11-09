module Taro::Config
  singleton_class.attr_accessor(
    :input_nesting,
    :parse_params,
    :response_nesting,
    :validate_params,
  )

  # defaults
  self.input_nesting = true
  self.parse_params = true
  self.response_nesting = true
  self.validate_params = true

  def self.invalid_response_callback
    if defined?(@invalid_response_callback)
      @invalid_response_callback
    else
      default_invalid_response_callback
    end
  end

  def self.default_invalid_response_callback
    if defined?(Rails.env.production?) && !Rails.env.production?
      ->(msg, details) { raise Taro::ResponseValidationError, "#{msg} - #{details}" }
    else
      ->(msg, details) { warn(msg, details) }
    end
  end

  def self.invalid_response_callback=(arg)
    arg.nil? || arg.respond_to?(:call) ||
      raise(ArgumentError, 'invalid_response_callback must be a nil or callable')
    @invalid_response_callback = arg
  end
end

def Taro.config
  Taro::Config
end
