class Taro::Rails::Declaration
  attr_reader :api, :params, :returns, :routes

  def initialize
    @params = Class.new(Taro::Types::InputType)
    @returns = {}
  end

  def api=(arg)
    arg.is_a?(String) || raise(Taro::ArgumentError, 'api description must be a String')
    @api = arg
  end

  def add_param(param_name, **kwargs)
    @params.field(param_name, **kwargs)
  end

  def add_return(field_name = nil, code:, **kwargs)
    status = self.class.coerce_status_to_int(code)
    returns[status] &&
      raise(Taro::ArgumentError, "response for status #{status} already declared")

    returns[status] = return_type_from(field_name, **kwargs)
  end

  def return_type_from(field_name, **kwargs)
    if field_name
      # TODO: allow anonymous types in openapi export, ref only their contents
      Class.new(Taro::Types::ObjectType).tap { |t| t.field(field_name, **kwargs) }
    else
      Taro::Types::Coercion.call(kwargs)
    end
  end

  def routes=(arg)
    arg.is_a?(Array) || raise(Taro::ArgumentError, 'routes must be an Array')
    @routes = arg
  end

  def parse_params(rails_params)
    hash = params.new(rails_params.to_unsafe_h).coerce_input
    params.new(hash).validate! if Taro.config.validate_params
    hash
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
