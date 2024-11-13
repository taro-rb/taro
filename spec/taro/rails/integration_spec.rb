require 'active_support'
require 'action_controller'
require 'action_controller/test_case'

describe 'Rails integration' do
  before do
    # fake railtie and action controller loading
    stub_rails(with_routes: routes)
    Taro::Rails::Railtie.initializers.each { |i| i.run(Rails.application) }
    ActiveSupport.run_load_hooks(:action_controller, nil)
    Rails.application.reloader.prepare!

    # do all the things needed to run the controller, phew ...
    extend ActionController::TestCase::Behavior
    allow(self.class).to receive(:controller_class).and_return(users_controller)
    @routes = ::ActionDispatch::Routing::RouteSet.new
    @routes.draw { put '/users', to: 'users#update' }
    setup_controller_request_and_response
  end

  let!(:routes) { [mock_user_route] }
  let!(:users_controller) do
    user_response_type # init

    stub_const('UsersController', Class.new(ActionController::API) do
      def self.name = 'UsersController'

      api 'my api'
      param :user, type: 'UserInputType', null: false
      returns type: 'UserResponseType', null: false, code: :ok
      def update
        render json: UserResponseType.render(name: @api_params[:user][:name].upcase)
      end
    end)
  end
  let!(:user_response_type) do
    stub_const('UserResponseType', Class.new(T::ObjectType) do
      field :name, type: 'String', null: false
    end)
  end
  let!(:user_input_type) do
    stub_const('UserInputType', Class.new(T::InputType) do
      field :name, type: 'String', null: false
    end)
  end

  it 'works' do
    expect(Taro::Rails.declarations.count).to eq 1

    put(:update, params: { user: { name: 'taro', id: '42' } })

    expect(response.body).to eq('{"name":"TARO"}')
    expect(Taro::Types::BaseType.used_in_response).to eq(UserResponseType)
  end

  it 'can raise errors for invalid params' do
    expect do
      put(:update, params: {})
    end.to raise_error(Taro::InputError)
  end

  it 'can raise errors for invalid response args' do
    expect(@controller).to receive(:update) do
      @controller.render json: UserResponseType.render(name: nil)
    end

    expect do
      put(:update, params: { user: { name: 'taro', id: '42' } })
    end.to raise_error(Taro::ResponseError)
  end

  it 'can raise errors for invalid response types' do
    stub_const('T', Class.new(T::ObjectType))
    expect(@controller).to receive(:update) { @controller.render json: T.render({}) }

    expect do
      put(:update, params: { user: { name: 'taro', id: '42' } })
    end.to raise_error(Taro::ResponseError, /expected.*UserResponseType/i)
  end

  it 'can raise errors for rendering without types' do
    expect(@controller).to receive(:update) { @controller.render json: {} }

    expect do
      put(:update, params: { user: { name: 'taro', id: '42' } })
    end.to raise_error(Taro::ResponseError, /expected.*UserResponseType/i)
  end
end
