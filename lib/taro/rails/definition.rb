class Taro::Rails::Definition
  attr_reader :api, :accepts, :returns, :routes

  def initialize(api: nil, accepts: nil, returns: nil, routes: [])
    self.api     = api if api
    self.accepts = accepts if accepts
    self.returns = returns if returns
    self.routes  = routes
  end

  def api=(arg)
    arg.is_a?(String) || raise(Taro::ArgumentError, 'api description must be a String')
    @api = arg
  end

  def accepts=(type)
    @accepts = Taro::Types::CoerceToType.from_string_or_hash!(type)
  end

  def returns=(hash)
    validated_hash = hash.to_h do |status, type|
      [
        self.class.coerce_status_to_int(status),
        Taro::Types::CoerceToType.from_string_or_hash!(type),
      ]
    end
    @returns = returns.to_h.merge(validated_hash)
  end

  def routes=(arg)
    arg.is_a?(Array) || raise(Taro::ArgumentError, 'routes must be an Array')
    @routes = arg
  end

  def parse_params(params)
    hash = params.to_unsafe_h
    accepts.new(hash).validate!
    params
  end

  def openapi_paths
    routes.to_a.map do |route|
      route.path.spec.to_s.gsub(/:(\w+)/, '{\1}').gsub('(.:format)', '')
    end
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
