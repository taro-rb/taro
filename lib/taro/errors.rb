class Taro::Error < StandardError; end
class Taro::ArgumentError < Taro::Error; end
class Taro::RuntimeError < Taro::Error; end
class Taro::ValidationError < Taro::RuntimeError; end
class Taro::ResponseValidationError < Taro::RuntimeError; end
