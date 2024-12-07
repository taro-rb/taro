desc 'Export all taro API declarations to a file'
task 'taro:export' => :environment do
  # make sure all declarations have been seen
  Rails.application.eager_load!

  title = Taro.config.api_name
  version = Taro.config.api_version
  format = Taro.config.export_format
  path = Taro.config.export_path
  # the generator / openapi version might become a config option later

  export = Taro::Export::OpenAPIv3.call(title:, version:)

  data = export.send("to_#{format}")

  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, data)

  puts "Exported the API #{title} v#{version} to #{path}"
end
