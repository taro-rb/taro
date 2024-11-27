Taro::Rails::NormalizedRoute = Data.define(:rails_route) do
  def ignored?
    verb.to_s.empty? || patch_update?
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
    rails_route.path.spec.to_s.gsub('(.:format)', '').gsub(/:(\w+)/, '{\1}')
  end

  def openapi_operation_id
    "#{verb}_#{action}_#{controller.gsub('/', '__')}"
  end

  def path_params
    openapi_path.scan(/{(\w+)}/).flatten.map(&:to_sym)
  end

  def endpoint
    "#{controller}##{action}"
  end

  def action
    rails_route.requirements[:action]
  end

  def controller
    rails_route.requirements[:controller]
  end

  def can_have_request_body?
    %w[patch post put].include?(verb)
  end

  def inspect
    %(#<#{self.class} "#{verb} #{openapi_path}">)
  end
  alias to_s inspect
end
