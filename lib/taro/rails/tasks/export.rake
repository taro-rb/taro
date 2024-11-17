desc 'Export all taro API declarations to a file'
task 'taro:export' => :environment do
  # make sure all declarations have been seen
  Rails.application.eager_load!

  # the generator / openapi version might become a config option later
  export = Taro::Export::OpenAPIv3.call(
    declarations: Taro::Rails.declarations,
    title: Taro.config.api_name,
    version: Taro.config.api_version,
  )

  data = export.send("to_#{Taro.config.export_format}")

  FileUtils.mkdir_p(File.dirname(Taro.config.export_path))
  File.write(Taro.config.export_path, data)

  puts "Exported #{Taro.config.api_name} to #{Taro.config.export_path}"
end
