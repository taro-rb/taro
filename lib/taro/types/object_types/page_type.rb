# Abstract base class for Page types (paginated ActiveRecord data).
# Unlike other types, this one should not be manually inherited from,
# but is used indirectly via `page_of: SomeType`.
#
# The gem rails_cursor_pagination must be installed to use this.
#
class Taro::Types::ObjectTypes::PageType < Taro::Types::BaseType
  extend Taro::Types::Shared::DerivableType
  extend Taro::Types::Shared::ItemType

  def self.render(object, after:, limit: 20, order_by: nil, order: nil)
    paginated_list = RailsCursorPagination::Paginator.new(
      object, limit:, order_by:, order:, after:
    ).fetch
    super(paginated_list)
  end

  def coerce_input
    raise Taro::RuntimeError, 'PageTypes cannot be used as input types'
  end

  def coerce_response
    item_type = self.class.item_type
    items = object[:page].map do |item|
      item_type.new(item[:data]).coerce_response
    end

    {
      self.class.items_key => items,
      page_info: Taro::Types::ObjectTypes::PageInfoType.new(object[:page_info]).coerce_response,
    }
  end

  # support overrides, e.g. based on item_type
  def self.items_key
    :page
  end
end
