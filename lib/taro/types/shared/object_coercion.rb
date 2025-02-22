# Provides input and response handling for types with fields.
module Taro::Types::Shared::ObjectCoercion
  def coerce_input
    validate_no_undeclared_params
    self.class.fields.transform_values do |field|
      field.value_for_input(object)
    end
  end

  # Render the object into a hash.
  def coerce_response
    object_is_hash = object.is_a?(Hash)
    self.class.fields.transform_values do |field|
      field.value_for_response(object, context: self, object_is_hash:)
    end
  end

  private

  def validate_no_undeclared_params
    return unless validate_no_undeclared_params?

    undeclared = object.to_h.keys.map(&:to_sym) - self.class.send(:field_defs).keys
    undeclared.any? && input_error("Undeclared params: #{undeclared.join(', ')}")
  end

  def validate_no_undeclared_params?
    Taro.config.raise_for_undeclared_params
  end
end
