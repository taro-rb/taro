require 'action_controller'

describe Taro::Rails::RouteFinder do
  let(:controller_class) { instance_double(ActionController::Base, controller_path: 'users') }

  it 'returns matching routes' do
    route = mock_user_route
    allow(described_class).to receive(:rails_routes).and_return([route])
    taro_routes = described_class.call(controller_class:, action_name: 'update')
    expect(taro_routes.map(&:rails_route)).to eq([route])
  end

  it 'returns an empty Array when no routes are found' do
    allow(described_class).to receive(:rails_routes).and_return([])
    expect(described_class.call(controller_class:, action_name: 'show')).to eq([])
  end

  it 'ignores routes without verb' do
    allow(described_class).to receive(:rails_routes).and_return([mock_user_route(verb: nil)])
    expect(described_class.send(:build_cache)).to be_empty
  end

  describe '::rails_routes' do
    it 'loads the routes if needed' do
      stub_rails
      expect(Rails.application).to receive(:reload_routes!)
      described_class.send(:rails_routes)
    end

    it 'does not load the routes if they are already loaded' do
      stub_rails(with_routes: [:some_route])
      expect(Rails.application).not_to receive(:reload_routes!)
      described_class.send(:rails_routes)
    end
  end
end
