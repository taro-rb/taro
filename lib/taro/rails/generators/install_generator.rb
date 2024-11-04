require 'rails/generators'
require 'rails/generators/base'

class Taro::Rails::Generators::InstallGenerator < ::Rails::Generators::Base
  desc 'Set up Taro base type files in your Rails app'

  class_option :dir, type: :string, default: "app/types"

  source_root File.expand_path("templates", __dir__)

  # :nocov:
  def create_type_files
    %w[
      base_type
      input_type
      object_type
      scalar_type
    ].each do |type|
      copy_file "#{type}.erb", "#{dir.chomp('/')}/#{type}.rb"
    end
  end
  # :nocov:
end
