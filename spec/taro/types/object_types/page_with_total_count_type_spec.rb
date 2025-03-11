require 'rails_cursor_pagination'

describe Taro::Types::ObjectTypes::PageWithTotalCountType do
  let(:example) { S::StringType.page_with_total_count }
  let(:page) { [] }
  let(:page_info) do
    { has_previous_page: true, has_next_page: true, start_cursor: 'x', end_cursor: 'y' }
  end
  let(:relation) { ActiveRecord::Relation.new }

  before do
    stub_const('ActiveRecord::Relation', Class.new)
    allow_any_instance_of(RailsCursorPagination::Paginator)
      .to receive(:fetch)
      .and_return(page:, page_info:)
  end

  it 'includes a total' do
    allow(relation).to receive(:count).and_return(42)
    result = example.render(relation, after: 'cursor')
    expect(result[:total_count]).to eq(42)
  end

  it 'has a default_openapi_name' do
    expect(example.default_openapi_name).to eq('string_PageWithTotalCount')
  end
end
