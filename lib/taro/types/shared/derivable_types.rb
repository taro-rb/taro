module Taro::Types::Shared::DerivableType
  def for(type)
    derived_types[type] ||= Class.new(self).tap { |t| t.item_type = type }
  end

  def derived_types
    @derived_types ||= {}
  end
end
