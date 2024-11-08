Taro::Rails::NormalizedRoute = Data.define(:rails_route) do
  def ok?
    !!verb && !patch_update?
  end

  # Journey::Route#verb is a String. Its usually something like 'POST', but
  # manual matched routes may have e.g. 'GET|POST' (🤢). We only need one copy.
  def verb
    rails_route.verb.to_s.scan(/\w+/).sort.last&.downcase
  end

  # Rails has both PATCH and PUT routes for updates. We only need one copy.
  def patch_update?
    verb == 'patch' && rails_route.requirements[:action] == 'update'
  end

  def openapi_path
    rails_route.path.spec.to_s.gsub(/:(\w+)/, '{\1}').gsub('(.:format)', '')
  end

  def endpoint
    controller, action = rails_route.requirements.values_at(:controller, :action)
    "#{controller}##{action}"
  end
end
