module Taro::Types::Shared::JSONRendering
  def render(object)
    result = new(object).coerce_response

    if Taro.config.response_nesting
      { nesting => result }
    else
      result
    end
  end

  def nesting
    @nesting ||= name.chomp('Type').gsub(/::|\B(?=\p{upper})/, '_').downcase
  end

  def nesting=(value)
    @nesting = value.to_s
  end
end
