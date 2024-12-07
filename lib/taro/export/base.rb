class Taro::Export::Base
  attr_reader :result

  def self.call(declarations: Taro.declarations, title: Taro.config.api_name, version: Taro.config.api_version, **)
    new.call(declarations:, title:, version:, **)
  end

  def to_json(*)
    require 'json'
    JSON.pretty_generate(result)
  end

  def to_yaml
    require 'yaml'
    desymbolize(result).to_yaml
  end

  private

  # https://github.com/ruby/psych/issues/396
  def desymbolize(arg)
    case arg
    when Hash   then arg.to_h { |k, v| [desymbolize(k), desymbolize(v)] }
    when Array  then arg.map { |v| desymbolize(v) }
    when Symbol then arg.to_s
    else             arg
    end
  end
end
