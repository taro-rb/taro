require_relative 'object_type'

# Abstract base class for rails declaration params. Internal use only.
class Taro::Types::RailsParamsType < Taro::Types::InputType
  # Skip validation of base params because they contain rails "additions"
  # like controller, action, routing-related stuff, de-nested values, etc.
  def validate_no_undeclared_params?
    false
  end
end
