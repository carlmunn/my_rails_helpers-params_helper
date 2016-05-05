require 'spec_helper'

describe MyRailsHelpers::ParamsHelper do

  def new_toggle(*args)
    MyRailsHelpers::ParamsHelper::Toggler.new(*args)
  end

  def _debug(msg)
    puts "\e[32m #{msg.inspect} \e[0m"
  end

  context 'parse options' do
    it 'should test basic option stucture without val' do
      s1 = {:opt => 'basic'}
      r1 = MyRailsHelpers::ParamsHelper::OptionBase.parse(s1)

      expect(r1.first).to be_instance_of MyRailsHelpers::ParamsHelper::Option
    end

    it 'should test basic option stucture' do
      s1 = {:opt => 'basic'}
      r1 = MyRailsHelpers::ParamsHelper::OptionBase.parse(s1)

      expect(r1.first).to be_instance_of MyRailsHelpers::ParamsHelper::Option
    end

    it 'should test basic stucture' do
      s2 = {:opt => {val: 'basic'} }
      r2 = MyRailsHelpers::ParamsHelper::OptionBase.parse(s2)
      expect(r2.first).to be_instance_of MyRailsHelpers::ParamsHelper::Option
    end

    it 'should test basic options stucture' do
      s3 = {:opt => {
        val: {
          :opt1 => true,
          :opt2 => true,
          :opt3 => true
        }
      }}

      r3 = MyRailsHelpers::ParamsHelper::OptionBase.parse(s3)
      expect(r3.first).to be_instance_of MyRailsHelpers::ParamsHelper::OptionCollection
    end

    it 'should test complicated options stucture with alias' do
      s4 = {:opt => {
        val: {
          :opt1 => {val: 'option', alias: 'option.alias'},
          :opt2 => true,
          :opt3 => true
        }
      }}

      r4 = MyRailsHelpers::ParamsHelper::OptionBase.parse(s4)
      expect(r4.first).to be_instance_of MyRailsHelpers::ParamsHelper::OptionCollection
    end

    it 'should test complicated options stucture' do
      s5 = {
        :opt => { val: {
          :opt1 => 'hello',
          :opt2 => 'hello2'
        }},
        :opt1 => 'basic'
      }
      
      r5 = MyRailsHelpers::ParamsHelper::OptionBase.parse(s5)

      expect(r5[0]).to be_instance_of MyRailsHelpers::ParamsHelper::OptionCollection
      expect(r5[1]).to be_instance_of MyRailsHelpers::ParamsHelper::Option
    end

    it 'should test with params' do
      r1 = MyRailsHelpers::ParamsHelper::OptionBase.parse({:opt => 'basic'}, {'opt' => 'basic'})
      expect(r1[0].default?).to eql true
    end
  end

  context 'options array' do
    it 'should test having an array as val' do
      toggler = new_toggle({}, {test: { val: [:opt1, :opt2] }})
      expect(toggler.get(:test).value).to eql :opt1
    end

    it 'should test returning array for values' do
      toggler = new_toggle({}, {test: { val: [:opt1, :opt2] }})
      expect(toggler.get(:test).values).to eql [:opt1, :opt2]
    end

    it 'should not over write the value when being passed as a param' do
      toggler = new_toggle({test: 'other'}, {test: { val: [:opt1, :opt2] }})
      expect(toggler.get(:test).values).to eql [:opt1, :opt2]
    end

    it 'should test false being the default' do
      toggler = new_toggle(nil, {test: { val: false }})
      
      expect(toggler.get(:test).on?).to eql false
      expect(toggler.get(:test)).to be_off
    end
  end
end
