require "spec_helper"

RSpec.describe TypeMap do
  describe '.get' do
    it 'returns the correct class for valid type symbols' do
      expect(TypeMap.get(:int)).to eq(Integer)
      expect(TypeMap.get(:str)).to eq(String)
      expect(TypeMap.get(:hash)).to eq(Hash)
      expect(TypeMap.get(:array)).to eq(Array)
      expect(TypeMap.get(:big_decimal)).to eq(BigDecimal)
      expect(TypeMap.get(:float)).to eq(Float)
      expect(TypeMap.get(:date)).to eq(Date)
      expect(TypeMap.get(:true)).to eq(TrueClass)
      expect(TypeMap.get(:false)).to eq(FalseClass)
    end

    it 'returns nil for unknown type symbols' do
      expect(TypeMap.get(:unknown)).to be_nil
      expect(TypeMap.get(:non_existent)).to be_nil
    end
  end

  context 'TypeMap type definitions' do    
    let(:base_types) {[
      :int, :str, :sym, :null, :true, :false, :hash, :array, :big_decimal, :float,
      :complex, :rational, :date, :date_time, :time, :any, :bool
    ]}

    let(:composite_types) do 
      {
        numeric: [:int, :float, :big_decimal],
        kernel_num: [:int, :float, :big_decimal, :complex, :rational],
        chrono: [:date, :date_time, :time]
      }
    end

    describe '.list_types' do
      it 'returns an array of all type symbols defined in TYPE_MAP' do
        expect(TypeMap.list_types).to match_array(base_types + composite_types.keys)
      end
    end

    describe 'TYPE_MAP constant' do
      it 'contains the expected keys' do
        expect(TypeMap::TYPE_MAP.keys).to match_array(base_types + composite_types.keys)
      end

      it 'maps composite types correctly' do
        expect(TypeMap::TYPE_MAP[:numeric]).to eq(composite_types[:numeric])
        expect(TypeMap::TYPE_MAP[:kernel_num]).to eq(composite_types[:kernel_num])
        expect(TypeMap::TYPE_MAP[:chrono]).to eq(composite_types[:chrono])
      end
    end
  end
end
