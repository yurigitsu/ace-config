require "spec_helper"

RSpec.describe AceDeck do
  let(:dummy_module) { Module.new { extend AceDeck } }
  let(:stng_values) {
    {
      one: 1,
      text: "Lorem Ipsum",
      float_point: 4.2,
      none: nil
    }
  }

  context "when nested namespace" do
    describe "declared typed #config" do
      let(:configs) do
        dummy_module.configure :settings do
          configure :nested do
            config :opt
            config.int :t_opt
            config :type_opt, type: :int
            config :cstm_type_opt, type: Integer
          end
        end
      end

      it "has #opt config param" do
        configs.settings.config(opt: stng_values[:text])
        expect(configs.settings.opt).to eq(stng_values[:text])
      end

      it "has #type_opt config param" do
        expect { configs.settings.nested.config(t_opt: stng_values[:text]) }.to raise_error(SettingTypeError)
      end

      it "has #t_opt config param" do
        expect { configs.settings.nested.config(type_opt: stng_values[:text]) }.to raise_error(SettingTypeError)
      end

      it "has #ctm_t_type_opt config param" do
        expect { configs.settings.nested.config(cstm_type_opt: stng_values[:text]) }.to raise_error(SettingTypeError)
      end

      it 'returns the type schema of the configuration' do
        configs.settings.nested.config(opt: stng_values[:text])
        configs.settings.nested.config(t_opt: stng_values[:int])
        configs.settings.nested.config(type_opt: stng_values[:int])
        configs.settings.nested.config(cstm_type_opt: stng_values[:int])

        expected_schema = { nested: { opt: :any, t_opt: :int, type_opt: :int, cstm_type_opt: Integer } }
        expect(configs.settings.type_schema).to eq(expected_schema)
      end

      it 'converts the configuration tree to a hash' do
        configs.settings.nested.config(opt: stng_values[:text])
        configs.settings.nested.config(t_opt: stng_values[:int])
        configs.settings.nested.config(type_opt: stng_values[:int])
        configs.settings.nested.config(cstm_type_opt: stng_values[:int])

        expected_hash = {  nested: { opt: stng_values[:text], t_opt: stng_values[:int], type_opt: stng_values[:int], cstm_type_opt: stng_values[:int] } }
        expect(configs.settings.to_h).to eq(expected_hash)
      end 

      it 'converts the configuration tree to JSON' do
        configs.settings.nested.config(opt: stng_values[:text])
        configs.settings.nested.config(t_opt: stng_values[:int])
        configs.settings.nested.config(type_opt: stng_values[:int])
        configs.settings.nested.config(cstm_type_opt: stng_values[:int])
       
        expected_json = { nested: { opt: stng_values[:text], t_opt: stng_values[:int], type_opt: stng_values[:int], cstm_type_opt: stng_values[:int] } }.to_json
        expect(configs.settings.to_json).to eq(expected_json)
      end

      it 'converts the configuration tree to YAML' do
        configs.settings.nested.config(opt: stng_values[:text])
        configs.settings.nested.config(t_opt: stng_values[:int])
        configs.settings.nested.config(type_opt: stng_values[:int])
        configs.settings.nested.config(cstm_type_opt: stng_values[:int])

        expected_yaml = { nested: { opt: stng_values[:text], t_opt: stng_values[:int], type_opt: stng_values[:int], cstm_type_opt: stng_values[:int] } }.to_yaml
        expect(configs.settings.to_yaml).to eq(expected_yaml)
      end
    end

    describe "#config" do
      let(:configs) do
        val = stng_values

        dummy_module.configure :settings do
          configure :nested do
            config one: val[:one]
            config.str text: val[:text]
            config float_point: val[:float_point], type: :float
            config none: val[:none], type: NilClass
          end
        end
      end

      it "has #one config param" do
        expect(configs.settings.nested.one).to eq(stng_values[:one])
      end

      it "has #text config param" do
        expect(configs.settings.nested.text).to eq(stng_values[:text])
      end

      it "has #one config param" do
        expect(configs.settings.nested.float_point).to eq(stng_values[:float_point])
      end

      it "has #text config param" do
        expect(configs.settings.nested.none).to eq(stng_values[:none])
      end

      it 'returns the type schema of the configuration' do
        expected_schema = { nested: { one: :any, text: :str, float_point: :float, none: NilClass } }
        expect(configs.settings.type_schema).to eq(expected_schema)
      end

      it 'converts the configuration tree to a hash' do
        expected_hash = { nested: { one: stng_values[:one], text: stng_values[:text], float_point: stng_values[:float_point], none: stng_values[:none] } }
        expect(configs.settings.to_h).to eq(expected_hash)
      end 

      it 'converts the configuration tree to JSON' do
        expected_json = { nested: { one: stng_values[:one], text: stng_values[:text], float_point: stng_values[:float_point], none: stng_values[:none] } }.to_json
        expect(configs.settings.to_json).to eq(expected_json)
      end

      it 'converts the configuration tree to YAML' do
        expected_yaml = { nested: { one: stng_values[:one], text: stng_values[:text], float_point: stng_values[:float_point], none: stng_values[:none] } }.to_yaml
        expect(configs.settings.to_yaml).to eq(expected_yaml)
      end 
    end
  end
end
