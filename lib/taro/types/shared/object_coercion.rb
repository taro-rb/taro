# Provides input and response handling for types with fields.
module Taro::Types::Shared::ObjectCoercion
  def coerce_input
    self.class.fields.transform_values do |field|
      field.value_for_input(object)
    rescue Taro::Error => e
      raise_enriched_coercion_error(e, field)
    end
  end

  # Render the object into a hash.
  def coerce_response
    object_is_hash = object.is_a?(Hash)
    self.class.fields.transform_values do |field|
      field.value_for_response(object, context: self, object_is_hash:)
    rescue Taro::Error => e
      raise_enriched_coercion_error(e, field)
    end
  end

  def raise_enriched_coercion_error(error, field)
    # The indentation is on purpose. These errors can be recursively rescued
    # and re-raised by a tree of object types, which should be made apparent.
    raise error.class, <<~MSG
      Failed to read #{self.class.name} field `#{field.name}` from #{object.class}:
      #{error.message.lines.map { |line| "  #{line}" }.join}
    MSG
  end
end
