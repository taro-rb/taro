RSpec.configuration.around(:each) do |example|
  if (cfg = example.metadata[:config]).is_a?(Hash)
    begin
      orig = cfg.to_h { |k, _v| [k, Taro.config.send("#{k}")] }
      cfg.each { |k, v| Taro.config.send("#{k}=", v) }

      example.run
    ensure
      orig.each { |k, v| Taro.config.send("#{k}=", v) }
    end
  else
    example.run
  end
end
