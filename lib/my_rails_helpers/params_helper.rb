require "my_rails_helpers/params_helper/store"
require "my_rails_helpers/params_helper/params_helper"
require "my_rails_helpers/params_helper/options"
require "my_rails_helpers/params_helper/version"

module MyRailsHelpers
  module ParamsHelper

    class Error < StandardError; end

    # DEBUG: Removes unnecessary items which I display back to the user
    def self.clean(params)
      params.delete_if {|k, v| ![:utf8, :authenticity_token, :commit, :action, :controller].include?(k.to_sym) } if params
    end

    def self.debug(msg)
      false && puts("\e[32m[D] #{msg}\e[0m"); 
    end
  end
end
