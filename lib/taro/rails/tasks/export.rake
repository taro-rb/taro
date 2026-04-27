desc 'Export all taro API declarations to a file'
task 'taro:export' => :environment do
  Taro::Export::OpenAPIv3.call.write_to_file

  puts "Exported the API #{Taro.config.api_name} " \
       "v#{Taro.config.api_version} to #{Taro.config.export_path}"
end
