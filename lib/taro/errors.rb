class Taro::Error < StandardError
  def message
    # clean up newlines introduced when setting the message with a heredoc
    super.chomp.tr("\n", ' ')
  end
end

class Taro::ArgumentError < Taro::Error; end
class Taro::RuntimeError < Taro::Error; end
class Taro::InvariantError < Taro::RuntimeError; end

class Taro::ValidationError < Taro::RuntimeError
  attr_reader :object, :origin

  def initialize(message, object, origin)
    raise 'Abstract class' if instance_of?(Taro::ValidationError)

    super(message)
    @object = object
    @origin = origin
  end
end

class Taro::InputError < Taro::ValidationError; end
class Taro::ResponseError < Taro::ValidationError; end
