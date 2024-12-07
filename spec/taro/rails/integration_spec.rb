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

      common_return code: 404, type: 'Boolean'

      api 'my api'
      param :user, type: 'UserInputType', null: false
      returns type: 'UserResponseType', code: :ok
      def update
        render json: UserResponseType.render(name: @api_params[:user][:name].upcase),
               status: params[:status] ? params[:status].to_i : :ok
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
    expect(Taro.declarations.count).to eq 1

    put(:update, params: { user: { name: 'taro', id: '42' } })

    expect(response.body).to eq('{"name":"TARO"}')
    expect(Taro::Types::BaseType.used_in_response).to eq(UserResponseType)
  end

  it 'applies common returns' do
    expect(Taro.declarations.first.returns)
      .to include(404 => S::BooleanType)
  end

  it 'raises when trying to override common returns' do
    expect { UsersController.returns(code: 404, type: 'String') }
      .to raise_error(Taro::ArgumentError, /already declared at .*#{__FILE__}/)
  end

  it 'can raise errors for invalid params' do
    expect do
      put(:update, params: {})
    end.to raise_error(Taro::InputError)
  end

  it 'can raise errors for invalid responses' do
    expect(@controller).to receive(:update) do
      @controller.render json: UserResponseType.render(name: nil)
    end

    expect do
      put(:update, params: { user: { name: 'taro', id: '42' } })
    end.to raise_error(Taro::ResponseError)
  end
end
