Taro::Rails::Definition = Struct.new(:api, :accepts, :returns) do
  def accepts=(type)
    validated_type = Taro::Types::CoerceToType.call(type)
    self[:accepts] = validated_type
  end

  def returns=(hash)
    validated_hash = hash.to_h do |status, type|
      [self.class.coerce_status_to_int(status), Taro::Types::CoerceToType.call(type)]
    end
    self[:returns] = returns.to_h.merge(validated_hash)
  end

  def parse_params(params)
    hash = params.to_unsafe_h
    hash = hash[accepts.nesting] if Taro.config.input_nesting
    accepts.new(hash).coerce_input
  end

  require 'rack'
  def self.coerce_status_to_int(status)
    # support using http status numbers directly
    return status if ::Rack::Utils::SYMBOL_TO_STATUS_CODE.key(status)

    # support using symbols, but coerce them to numbers
    ::Rack::Utils::SYMBOL_TO_STATUS_CODE[status] ||
      raise(Taro::ArgumentError, "Invalid status: #{status.inspect}")
  end
end
