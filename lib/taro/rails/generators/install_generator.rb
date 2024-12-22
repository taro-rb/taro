require 'rails/generators'
require 'rails/generators/base'

class Taro::Rails::Generators::InstallGenerator < ::Rails::Generators::Base
  desc 'Set up Taro base type files in your Rails app'

  class_option :dir, type: :string, default: "app/types"

  source_root File.expand_path("templates", __dir__)

  # :nocov:
  def create_type_files
    Dir["#{self.class.source_root}/**/*.erb"].each do |tmpl|
      dest_dir = options[:dir].chomp('/')
      template tmpl, "#{dest_dir}/#{File.basename(tmpl, '.erb')}.rb"
    end
  end
  # :nocov:
end
