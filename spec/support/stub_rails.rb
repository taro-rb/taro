def stub_rails(with_routes: [])
  rails = Module.new { def self.name = 'Rails'; def self.env = 'test' }
  config = instance_double(Rails::Application::Configuration)
  allow(config).to receive(:after_initialize) { |&block| block.call }
  allow(rails).to receive(:cache).and_return(DUMMY_CACHE)
  application = instance_double(
    Rails::Application,
    env_config: {},
    reloader: ActiveSupport::Reloader,
    reload_routes!: true,
    routes: instance_double(ActionDispatch::Routing::RouteSet, routes: with_routes),
    config:,
  )
  rails.define_singleton_method(:application) { application }
  stub_const('Rails', rails)
end

def mock_user_route(verb: 'PUT', action: 'update')
  instance_double(
    ActionDispatch::Journey::Route,
    path: instance_double(
      ActionDispatch::Journey::Path::Pattern,
      spec: instance_double(ActionDispatch::Journey::Nodes::Cat, to_s: '/users/:id(.:format)'),
    ),
    requirements: { controller: 'users', action: },
    verb:,
  )
end

def stub_declaration_routes(declaration, *routes)
  allow(declaration)
    .to receive(:routes)
    .and_return(routes.map { |r| Taro::Rails::NormalizedRoute.new(r) })
end
