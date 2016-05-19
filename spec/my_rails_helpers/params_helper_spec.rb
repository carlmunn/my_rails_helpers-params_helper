require 'spec_helper'
require 'byebug'

describe MyRailsHelpers::ParamsHelper do

  def new_toggle(*args)
    MyRailsHelpers::ParamsHelper::Toggler.new(*args)
  end

  def _debug(msg)
    puts "\e[32m #{msg.inspect} \e[0m"
  end

  it 'has a version number' do
    expect(MyRailsHelpers::ParamsHelper::VERSION).not_to be nil
  end

  it 'does something useful' do
    toggler = new_toggle({}, {collection: {val: ['opt1', 'opt2', 'opt3']}})
  end

  context 'true false values' do
    it 'should test basic true/false value' do
      toggler = new_toggle({}, {truefalse: {val: true}})
      expect(toggler.get(:truefalse)).to be_on
    end

    it 'should return the value passed in the param' do
      toggler = new_toggle({truefalse: false}, {truefalse: {val: true}})
      expect(toggler.get(:truefalse)).to be_off
    end
  end

  context 'collection of options' do

    let(:defaults) do
      {val: {
        opt1: false,
        opt2: false,
        opt3: false
      }}
    end

    it 'should return an array of options' do
      toggle = new_toggle({}, {collection: defaults})
      expect(toggle.get(:collection).options).to_not be_empty
    end

    it 'should test options are all on except for opt3' do

      toggle = new_toggle({collection: ['opt1', 'opt2']}, collection: defaults)
      result = toggle.get(:collection)

      expect(result.options.size).to eql 3

      expect(result.find('opt1')).to be_on
      expect(result.find('opt2')).to be_on
      expect(result.find('opt3')).to be_off
    end
  end

  context 'passed string option' do
    it 'should return the value that was passed' do
      toggler  = new_toggle({selected: 'passed-option'}, {selected: {val: 'opt1'}})
      expect(toggler.get(:selected).value).to eql 'passed-option'
      expect(toggler.get(:selected)).to_not be_default
    end

    it 'should return the value that was passed' do
      toggler  = new_toggle({selected: 'opt1'}, {selected: {val: 'opt1'}})
      expect(toggler.get(:selected).value).to eql 'opt1'
      expect(toggler.get(:selected)).to be_default
    end
  end

  # These are just one hit wonders, either they are on or off
  context 'basic' do
    it 'should test all off' do
      toggler = new_toggle({}, {
        opt1: {val: false},
        opt2: {val: false},
        opt3: {val: false}
      })

      # Returns true which will be used by the UI to switch to a different state
      expect(toggler.get(:opt1).value).to eql false
      expect(toggler.get(:opt2).value).to eql false
      expect(toggler.get(:opt3).value).to eql false
    end

    it 'should test a sibling being set' do
      toggler = new_toggle({opt3: true}, {
        opt1: {val: false},
        opt2: {val: false},
        opt3: {val: false}
      })

      expect(toggler.get(:opt1)).to_not be_on
      expect(toggler.get(:opt3)).to be_on
    end

    # Was using this for HTML A tags but changed to a form. left here because it may we used some stage
    #
    # Because the option is for opt1 it should be flip back to false which means it's a default now
    # therefore it doesn't need to be within
  end

  context 'returning array of options' do
    let(:defaults) do
      {val: {
        opt1: true,
        opt2: false,
        opt3: false
      }}
    end

    it 'should return an array of options; options unaffect because it was not in the filter' do
      toggle = new_toggle({}, {collection: defaults})
      expect(toggle.get(:collection).values).to_not be_empty
    end

    it 'should flip what is returned in the array of options' do
      toggle  = new_toggle({}, {collection: defaults})
      results = toggle.get(:collection).values(flip: true)

      expect(results).to_not include 'opt1'
      expect(results).to include 'opt2'
      expect(results).to include 'opt3'
    end

    it 'should ignore if the values are default' do
      toggle = new_toggle({}, {collection: defaults})
      expect(toggle.get(:collection).values(ignore: :defaults)).to_not include 'opt1'
    end

    it 'should pass the selected option along' do
      params  = {collection: ['opt1', 'opt2']}
      default = {collection: {val: {opt1: true, opt2: false}}}
      toggle = new_toggle(params, default)

      expect(toggle.get(:collection).values).to eql ['opt1', 'opt2']
    end

    it 'should flip the selected option' do
      params  = {collection: ['opt1']}
      default = {collection: {val: {opt1: true, opt2: false}}}
      toggle = new_toggle(params, default)

      expect(toggle.get(:collection).values(flip: true)).to eql ['opt2']
    end

    it 'should flip the selected option except for the value missing' do
      params  = {collection: ['opt1']}
      default = {collection: {val: {opt1: true, opt2: true}}}
      toggle = new_toggle(params, default)

      expect(toggle.get(:collection).values(flip: true)).to eql ['opt2']
    end
  end

  context 'aliases' do
    it 'should convert the value based on the alias set' do

      toggler = new_toggle({}, {test: { val: :option, alias: {option: 'record.id'} }})

      expect(toggler.get(:test).value).to eql 'record.id'
    end
  end

  context 'booleans' do
    it 'should return true' do
      toggler = new_toggle({}, {test: {val: true}})
      expect(toggler.get(:test).value).to eql true
    end

    it 'should return false' do
      toggler = new_toggle({}, {test: {val: false}})
      expect(toggler.get(:test).value).to eql false
    end

    it 'should return true from params "1"' do
      toggler = new_toggle({test: '1'}, {test: {val: false}})
      expect(toggler.get(:test).value).to eql true
    end

    it 'should return true from params "true"' do
      toggler = new_toggle({test: 'true'}, {test: {val: false}})
      expect(toggler.get(:test).value).to eql true
    end

    it 'should return false from params "0"' do
      toggler = new_toggle({test: '0'}, {test: {val: true}})
      expect(toggler.get(:test).value).to eql false
    end

    it 'should return false from params "false"' do
      toggler = new_toggle({test: 'false'}, {test: {val: true}})
      expect(toggler.get(:test).value).to eql false
    end

    it 'should handle boolean when fresh' do
      toggle = new_toggle(nil, {test: true} )
      expect(toggle.get(:test)).to be_on
    end

    it 'should handle "1" when default it true' do
      toggle = new_toggle({test: '1'}, {test: {val: true}} )
      expect(toggle.get(:test)).to be_on
    end

    it 'should handle "0" when default is true using #on?' do
      toggle = new_toggle({test: '0'}, {test: {val: true}} )
      expect(toggle.get(:test)).to be_off
    end
  end

  # Could the other lookup methods as tests but params being passed as strings is important
  context 'string keys' do
    it 'should find the value using a string as a key' do
      toggler = new_toggle({'test' => 'other-option'}, {test: {val: 'option'}})
      expect(toggler.get(:test).value).to eql 'other-option'
    end
  end

  context 'setting option' do
    it 'should test setting the value' do
      toggler = new_toggle({}, {option: {val: nil}})
      toggler.get(:option).value = 'new-value'
      expect(toggler.get(:option).value).to eql 'new-value'
    end
  end
end
