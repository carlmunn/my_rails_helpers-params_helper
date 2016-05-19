$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'my_rails_helpers/params_helper'

def _debug(msg)
  puts "\e[32m #{msg.inspect} \e[0m"
end