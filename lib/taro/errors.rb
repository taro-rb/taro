class Taro::Error < StandardError; end
class Taro::ArgumentError < Taro::Error; end
class Taro::RuntimeError < Taro::Error; end
class Taro::ValidationError < Taro::RuntimeError; end # not to be used directly
class Taro::InputError < Taro::ValidationError; end
class Taro::ResponseError < Taro::ValidationError; end
