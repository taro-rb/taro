describe Taro::Types::ObjectTypes::PageType do
  let(:page_info) do
    { has_previous_page: true, has_next_page: true, start_cursor: 'x', end_cursor: 'y' }
  end

  it 'can not coerce input' do
    expect do
      S::StringType.page.new('foo').coerce_input
    end.to raise_error(Taro::RuntimeError, 'PageTypes cannot be used as input types')
  end

  it 'coerces response data' do
    type = S::StringType.page
    expect(type.new({ page: [], page_info: }).coerce_response).to eq(page: [], page_info:)
    expect(type.new({ page: [{ data: 'x' }], page_info: }).coerce_response).to eq(page: %w[x], page_info:)
    expect(type.new({ page: [{ data: 42 }], page_info: }).coerce_response).to be_nil
  end

  it 'renders with rails_cursor_pagination' do
    require 'rails_cursor_pagination'

    stub_const('ActiveRecord::Relation', Class.new)
    allow_any_instance_of(RailsCursorPagination::Paginator)
      .to receive(:fetch)
      .and_return(page: [], page_info:)

    S::StringType.page.render(ActiveRecord::Relation.new, after: 'x')
  end

  it 'has a default_nesting for contents without own nesting' do
    expect(S::StringType.page.nesting).to eq :page
  end

  it 'has a default_nesting for complex type content' do
    obj_type = Class.new(T::ObjectType)
    obj_type.define_singleton_method(:name) { 'ObjType' }
    expect(obj_type.page.nesting).to eq :obj_page
  end
end
