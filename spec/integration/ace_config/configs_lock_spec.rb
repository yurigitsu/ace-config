require "spec_helper"
require "pry"

RSpec.describe "Configs::lock" do
  let(:stng_values) do
    {
      one: 1,
      text: "Lorem Ipsum",
      float_point: 4.2,
      none: nil
    }
  end

  context "when flat namespace" do
    let(:configs) do
      suppoert_dummy_instance_settings.new.tap do |obj|
        obj.settings do
          config.int opt: 1, lock: false
          # config.int :opt, lock: true
          # config.int opt: 1
          # config.int opt: 1, lock: false
          # config :dsl_opt
          # config.int :t_opt
          # config :type_opt, type: :int
          # config :cstm_type_opt, type: Integer
        end
      end
    end

    it "wip" do
      # configs.settings.config(opt: 2, lock: false)
      # configs.settings.config(opt: 2)
      configs.settings.config(opt: 3)

      configs.settings.config(opt: 2, lock: true)
      configs.settings.config(opt: 3, lock: false)
      configs.settings.config(opt: 10)

      expect(configs.settings.opt).to eq(2)
    end
  end
end
