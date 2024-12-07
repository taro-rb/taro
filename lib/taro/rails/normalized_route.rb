require_relative '../route'

class Taro::Rails::NormalizedRoute < Taro::Route
  def initialize(rails_route)
    action, controller = rails_route.requirements.values_at(:action, :controller)
    # Journey::Route#verb is a String. Its usually something like 'POST', but
    # manual matched routes may have e.g. 'GET|POST' (🤢). We only need one copy.
    verb = rails_route.verb.to_s.scan(/\w+/).sort.last.to_s.downcase
    openapi_operation_id = "#{verb}_#{action}_#{controller}".gsub('/', '__')
    openapi_path = rails_route.path.spec.to_s.gsub('(.:format)', '').gsub(/:(\w+)/, '{\1}')
    endpoint = "#{controller}##{action}"

    super(endpoint:, openapi_operation_id:, openapi_path:, verb:)
  end

  def ignored?
    internal? || patch_update?
  end

  private

  # Internal routes of rails sometimes have no verb.
  def internal?
    verb.empty?
  end

  # Rails has both PATCH and PUT routes for updates. We only need one copy.
  def patch_update?
    verb == 'patch' && endpoint.end_with?('#update')
  end
end
