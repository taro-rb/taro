module Taro::Types::Shared::DerivedTypes
  def list
    @list ||= Class.new(Taro::Types::ListType).tap { |t| t.item_type = self }
  end

  def page
    @page ||= Class.new(Taro::Types::ObjectTypes::PageType).tap { |t| t.item_type = self }
  end
end
