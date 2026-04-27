describe Taro::Export::Base do
  describe '.call' do
    let(:dummy_pass_through_export) do
      Class.new(Taro::Export::Base) do
        def call(declarations:, **)
          declarations.to_a
        end
      end
    end

    it 'exports all declarations by default' do
      Taro.declarations['foo'] = 'normal1'
      Taro.declarations['bar'] = 'normal2'
      result = dummy_pass_through_export.call
      expect(result).to eq %w[normal1 normal2]
    end

    it 'exports custom declarations if given' do
      result = dummy_pass_through_export.call(declarations: %w[custom1 custom2])
      expect(result).to eq %w[custom1 custom2]
    end
  end

  describe '#write_to_file' do
    it 'writes the exported API definition to a file' do
      export = Taro::Export::Base.new
      allow(export).to receive(:result).and_return(42)
      path = File.join(Dir.tmpdir, "#{rand}.test")

      export.write_to_file(path:, format: :json)

      expect(File.read(path)).to eq('42')
    ensure
      File.delete(path) if path && File.exist?(path)
    end
  end
end
