# Abstract base class for Page types (paginated ActiveRecord data).
# Unlike other types, this one should not be manually inherited from,
# but is used indirectly via `SomeType.page`.
#
# The gem rails_cursor_pagination must be installed to use this.
#
class Taro::Types::ObjectTypes::PageType < Taro::Types::BaseType
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
      res = item_type.new(item[:data]).coerce_response
      res.nil? ? break : res
    end
    return unless items

    {
      self.class.nesting => items,
      page_info: Taro::Types::ObjectTypes::PageInfoType.new(object[:page_info]).coerce_response,
    }
  end

  def self.default_nesting
    item_type.nesting&.then { |n| "#{n}_page" } || 'page'
  end
end
