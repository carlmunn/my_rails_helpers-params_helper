require 'spec_helper'

describe MyRailsHelpers::ParamsHelper do

  def new_toggle(*args)
    MyRailsHelpers::ParamsHelper::Toggler.new(*args)
  end

  def _debug(msg)
    puts "\e[32m #{msg.inspect} \e[0m"
  end

  context 'defaults' do

    let(:defaults) do
      {val: {
        opt1: false,
        opt2: false,
        opt3: false
      }}
    end

    it 'should all be defaults because the option was not in the filter' do

      toggle = new_toggle({}, collection: defaults )
      result = toggle.get(:collection)

      expect(result.find('opt1')).to be_default
      expect(result.find('opt2')).to be_default
      expect(result.find('opt3')).to be_default
    end

    # This checks OptionCollection#values method which relies on the #default? method
    it 'should return the correct default values' do
      toggler = new_toggle(nil, {test: {val: { opt1: true, opt2: true, opt3: false }}})   
      expect(toggler.get(:test).values).to eql ['opt1', 'opt2']
    end

    it 'should all be default as the options are the same' do
      new_defaults = defaults.tap {|h| h[:val][:opt1] = true }

      toggle = new_toggle({collection: ['opt1']}, collection: new_defaults )
      result = toggle.get(:collection)

      expect(result.find('opt1')).to be_default
      expect(result.find('opt2')).to be_default
      expect(result.find('opt3')).to be_default
    end

    it 'should contain one that is not default' do

      toggle = new_toggle({collection: ['opt1']}, collection: defaults )
      result = toggle.get(:collection)

      expect(result.find('opt1')).to_not be_default
      expect(result.find('opt2')).to be_default
      expect(result.find('opt3')).to be_default
    end

    it 'should be default because there is no string in the filter' do
      toggle = new_toggle({}, filter: 'search-string' )
      expect(toggle.get(:filter)).to be_default
    end

    it 'should return default as the string is the same in the filter' do
      toggle = new_toggle({filter: 'search-string'}, filter: 'search-string' )
      expect(toggle.get(:filter)).to be_default
    end

    it 'should not be default because the string has changed' do
      toggle = new_toggle({filter: 'different-string'}, filter: 'search-string' )
      expect(toggle.get(:filter)).to_not be_default
    end
  end
end
