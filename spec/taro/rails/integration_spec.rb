require 'active_support'
require 'action_controller'
require 'action_controller/test_case'

describe 'Rails integration' do
  it 'works' do
    # fake railtie and action controller loading
    Taro::Rails::Railtie.initializers.each(&:run)
    ActiveSupport.run_load_hooks(:action_controller_base, nil)

    input_type = Class.new(Taro::Types::InputType)
    input_type.define_singleton_method(:name) { 'UserInputType' }
    input_type.field(:name) { [String, null: false] }

    controller_class = Class.new(ActionController::Base) do
      def self.name = 'UsersController'

      api 'my api'
      accepts input_type
      returns ok: String
      def show
        render json: @api_params[:name].upcase
      end
    end

    # do all the things needed to run tho controller, phew ...
    extend ActionController::TestCase::Behavior
    allow(self.class).to receive(:controller_class).and_return(controller_class)
    @routes = ::ActionDispatch::Routing::RouteSet.new
    @routes.draw { get '/users', to: 'users#show' }
    setup_controller_request_and_response

    get(:show, params: { user: { name: 'taro' } })

    expect(response.body).to eq('TARO')
  end
end
