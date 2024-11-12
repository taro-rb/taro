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

  data = export.result.send("to_#{Taro.config.export_format}")
  File.write(Taro.config.export_path, data)
end
