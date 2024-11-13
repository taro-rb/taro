class Taro::Types::ObjectTypes::FreeFormType < Taro::Types::ObjectType
  self.desc = 'An arbitrary, unvalidated Hash or JSON object. Use with care.'
  self.additional_properties = true

  def coerce_input
    object.is_a?(Hash) && object || input_error('must be a Hash')
  end

  def coerce_response
    object.respond_to?(:as_json) && (res = object.as_json).is_a?(Hash) && res ||
      response_error('must return a Hash from #as_json')
  end
end
