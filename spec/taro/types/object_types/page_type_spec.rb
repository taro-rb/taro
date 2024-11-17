require 'rails_cursor_pagination'

describe Taro::Types::ObjectTypes::PageType do
  let(:example) { S::StringType.page }
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

  it 'can not coerce input' do
    expect do
      example.new('foo').coerce_input
    end.to raise_error(Taro::Error, /PageTypes cannot be used as input types/)
  end

  it 'coerces response data' do
    expect(example.new(relation).coerce_response(after: 'cursor'))
      .to eq(page: [], page_info:)

    page << { data: 'x' }
    expect(example.new(relation).coerce_response(after: 'cursor'))
      .to eq(page: %w[x], page_info:)
  end

  it 'raises for items that do not match the item type' do
    page << { data: 42 }
    expect do
      example.new(relation).coerce_response(after: 'cursor')
    end.to raise_error(
      Taro::ResponseError,
      'Integer is not valid as String: must be a String or Symbol'
    )
  end

  it 'takes kwargs for ::render and passes on pagination args' do
    expect(RailsCursorPagination::Paginator)
      .to receive(:new)
      .with(relation, hash_including(after: 'cursor'))
      .and_call_original
    result = example.render(relation, after: 'cursor')
    expect(result).to eq(page: [], page_info:)
  end

  it 'can use a custom key items_key for nesting the items' do
    expect(example.render(relation, after: 'cursor', items_key: 'foos'))
      .to eq(foos: [], page_info:)
  end

  it 'raises if after kwarg is missing for ::render' do
    expect { example.render(relation) }.to raise_error(/after/)
  end
end
