require 'spec_helper'

class TestFieldsCache < Cache::Base
  include Cache::Exts::Fields

  FIELDS = %w[field1 field2]

  def cache_store
    @cache_store ||= Object.new
  end

  def cache_store_call_options
    {some: :option}
  end
end

describe TestFieldsCache do

  describe "#fetch" do
    let(:key) { double("key") }
    let(:object) { double("object", field1: 'aaa', field2: 123) }

    context 'present? and blank? methods are not defined in Hash' do
      it 'should load missed object as mash with given fields' do
        expect(subject.cache_store).to receive(:read).and_return(nil)
        expect(subject).to receive(:load_object).with(key).and_return(object)
        expect(subject.cache_store).to receive(:write)

        value = subject.fetch(key)
        expect(value.field1).to eq 'aaa'
        expect(value.field2).to eq 123
        expect(value.blank?).to eq false
        expect(value.present?).to eq true
      end
    end

    context 'present? and blank? methods already exist in Hash' do
      before do
        Hash.define_method(:blank?) { false }
        Hash.define_method(:present?) { true }
      end

      it 'should not add blank? and present? keys unless missed' do
        expect(subject.cache_store).to receive(:read).and_return(nil)
        expect(subject).to receive(:load_object).with(key).and_return(object)
        expect(subject.cache_store).to receive(:write)


        value = subject.fetch(key)
        expect(value.field1).to eq 'aaa'
        expect(value.field2).to eq 123
        expect(value.blank?).to eq false
        expect(value.present?).to eq true
      end
    end
  end

end
