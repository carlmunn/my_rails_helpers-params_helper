require 'spec_helper'

describe MyRailsHelpers::ParamsHelper do

  def user
    user = double(:user)
    user.stub(:id).and_return('UserID')
    user.stub(:id).and_return('UserID')
  end

  def new_toggle(*args)
    MyRailsHelpers::ParamsHelper::Toggler.new(*args)
  end

  pending 'should test saving to storage' do
    toggler = new_toggle({}, {option: {val: 'VALUE'}})
    toggler.save(user: user, namespace: 'namespace')
  end
end