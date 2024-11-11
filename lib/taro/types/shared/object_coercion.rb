# Provides input and response handling for types with fields.
module Taro::Types::Shared::ObjectCoercion
  def coerce_input
    self.class.fields.to_h do |name, field|
      value = field.coerce_input(object)
      [name, value]
    end
  end

  # Render the object into a hash.
  def coerce_response
    object_is_hash = object.is_a?(Hash)
    self.class.fields.to_h do |name, field|
      value = field.extract_value(object, context: self, object_is_hash:)
      [name, value]
    end
  end
end
