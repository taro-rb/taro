# Provides coercion and validation for the "inner" type of enums and arrays.
module Taro::Types::Shared::ItemType
  attr_reader :item_type

  def item_type=(new_type)
    item_type.nil? || new_type == item_type || raise_mixed_types(new_type)
    @item_type = new_type
  end

  def raise_mixed_types(new_type)
    raise Taro::ArgumentError, <<~MSG
      All items must be of the same type. Mixed types are not supported for now.
      Expected another #{item_type} item but got a #{new_type} for #{self}.
    MSG
  end
end
