require 'rack'

module Taro::StatusCode
  def self.coerce_to_int(arg)
    # support using http status numbers directly
    return arg if ::Rack::Utils::SYMBOL_TO_STATUS_CODE.key(arg)

    # support using symbols, but coerce them to numbers
    ::Rack::Utils::SYMBOL_TO_STATUS_CODE[arg] ||
      raise(Taro::ArgumentError, "Invalid status: #{arg.inspect}")
  end
end
