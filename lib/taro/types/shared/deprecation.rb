module Taro::Types::Shared::Deprecation
  attr_reader :deprecated

  def deprecated=(value)
    @deprecated = value ? true : nil
  end
end
