class Taro::Error < StandardError; end
class Taro::ArgumentError < Taro::Error; end
class Taro::RuntimeError < Taro::Error; end
class Taro::ValidationError < Taro::Error; end
class Taro::ResponseValidationError < Taro::Error; end
