require 'active_support'
require 'action_controller'
require 'action_controller/test_case'

describe 'Rails integration' do
  it 'works' do
    # fake railtie and action controller loading
    stub_rails(with_routes: [mock_user_route])
    Taro::Rails::Railtie.initializers.each { |i| i.run(Rails.application) }
    ActiveSupport.run_load_hooks(:action_controller_base, nil)
    Rails.application.reloader.prepare!

    stub_const('UserInputType', Class.new(T::InputType) do
      field :name, type: 'String', null: false
    end)

    stub_const('UserResponseType', Class.new(T::ObjectType) do
      field :name, type: 'String', null: false
    end)

    controller_class = Class.new(ActionController::Base) do
      def self.name = 'UsersController'

      api 'my api'
      param :user, type: 'UserInputType', null: false
      returns type: 'UserResponseType', null: false, code: :ok
      def show
        render json: UserResponseType.render(name: @api_params[:user][:name].upcase)
      end
    end

    # do all the things needed to run tho controller, phew ...
    extend ActionController::TestCase::Behavior
    allow(self.class).to receive(:controller_class).and_return(controller_class)
    @routes = ::ActionDispatch::Routing::RouteSet.new
    @routes.draw { get '/users', to: 'users#show' }
    setup_controller_request_and_response

    get(:show, params: { user: { name: 'taro', id: '42' } })

    expect(response.body).to eq('{"name":"TARO"}')
  end
end
