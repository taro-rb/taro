def stub_rails(with_routes: [])
  rails = Module.new { def self.name = 'Rails' }
  application = instance_double(
    Rails::Application,
    env_config: {},
    reloader: ActiveSupport::Reloader,
    reload_routes!: true,
    routes: instance_double(ActionDispatch::Routing::RouteSet, routes: with_routes),
  )
  rails.define_singleton_method(:application) { application }
  stub_const('Rails', rails)
end

def mock_user_route(verb: 'GET')
  instance_double(
    ActionDispatch::Journey::Route,
    path: instance_double(
      ActionDispatch::Journey::Path::Pattern,
      spec: instance_double(ActionDispatch::Journey::Nodes::Cat, to_s: '/users/:id'),
    ),
    requirements: { controller: 'users', action: 'show' },
    verb:,
  )
end
