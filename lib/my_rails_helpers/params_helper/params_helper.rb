# Handles string boolean values

# One level deep at the moment

# Support for storage, cookies or internal storage

# International, i18n

# Usage?

module MyRailsHelpers
  module ParamsHelper
    class Toggler

      include MyRailsHelpers::ParamsHelper::Store

      def initialize(params=nil, opts={})

        @fresh   = !params
        @params  = (params ? params.dup : {})
        @opts    = OptionBase.parse(opts, params)
        
        # Clean up the original params, we don't need to show defaults in the params
        filter_defaults(params) if params

        #_debug("Setup: fresh:#{@fresh}\n\nparams: #{@params}\n\nopts: #{@opts}")
      end

      # Gets the value if defined, otherwise it returns the default value
      # +ignore+ defines what to ignore
      def get(key, ignore: nil)
        if option = find(key)
          option.first
        else
          nil
        end
      end 

      # Returns true if the param is set to the one supplied
      # Ignored if the default is set as the value
      #
      # Used for links
      #def selected?(key, value=get_param(key))
      #  !_blank?(value) && get_default(key) != value
      #end

      # Return the other params that need to be carried over because they aren't defaults
      # This is meant to be used in the view as it will overwrite the default
      #
      # Used for links
      def options_with(key=nil, value=get_default(key))
        r = get_changes.tap {|h| h[key] ||= value if key }
        r[key] = !r[key] if _is_bool?(r[key]) # Flip
      end

      # This isn't going to work well when the form needs to reverse
      # the value because it was used in the controller.
      def method_missing(method, *args)
        if opt = get(method)
          opt.value
        else
          raise NoMethodError, method
        end
      end

    private
      # Returns array/value for the specified option
      def get_selected(key)
        option = find(key)

        if option.is_a?(Option)
          _debug("get_selected: found Option #{option}")
          option
        elsif option
          _debug("get_selected: found OptionCollection #{option}")
          option
        else
          raise MyRailsHelpers::ParamsHelper::Error, "Option for '#{key}' not found in (#{@opts.inspect})"
        end
      end

      def fetch_param(key)
        get_default(key)
      end

      def get_param(key)
        convert_boolean(key)
        @params[key]
      end

      def filter_defaults_collection(key, params)
        collection = get_param(key) || {}

        collection_opts = find(key)[:val]

        #_debug "#{@params}c ollection:#{key} #{collection} collection_opts: #{collection_opts} #{collection_opts.size}"

        r = collection_opts.collect do |k, v|

          #_debug "r.....: #{collection[k]}"

          _blank?(collection[k])

          collection[k] == get_default(k)

          #if _blank?(collection[k]) || get_param(k) == get_default(k)
          #  params.delete(k)
          #end
        end

        #_debug "r.....: #{r}"
        r
      end

      # Clear out the defaults and make the URL pretty. We don't need to but it makes
      # things nicer to look at.
      def filter_defaults(params)
        @opts.each do |k, v|
          if _blank?(get_param(k.name)) || get_param(k.name) == get_default(k.name)
            params.delete(k.name)
          end
        end

        params
      end

      def get_options
        @opts.inject({}) do |seed, (k, v)|
          value = get_param(k) || get_default(k)
          seed.merge!(k => value)
          seed
        end
      end

      # The changes are params that changed from what is set in the default
      def get_changes
        @opts.inject({}) do |seed, (k, v)|

          value = get_param(k) || get_default(k)

          seed.merge!(k => value) if _keep_value?(k)

          seed
        end
      end

      def _keep_value?(key)

        # 1. The value exists in the options
        return true if find(key).nil?

        # 2. The value isn't blank
        param_option  = _boolinze(get_param(key))
        return false if _blank?(param_option)

        # 3. The param value isn't the same as the default value
        return true  if param_option != _boolinze(get_default(key))

        false
      end

      def get_default(key)

        val = find(key)

        if val.is_a?(Hash)
          val[:val]
        else
          val
        end
      end

      # Dealing with boolean internally
      def convert_boolean(key)
        @params[key] = _boolinze(@params[key]) if _is_bool?(get_default(key))
      end

      # Strings can represent boolean
      def _boolinze(val)
        return true if ['true', '1'].include?(val)
        return false if ['false', '0'].include?(val)
        val
      end

      def _is_bool?(v)
        !!v == v
      end

      def find(key)
        @opts.select {|obj| obj.name == key.to_sym || obj.name == key.to_s }
      end

      # This is native in Rails
      def _blank?(value)
        value.nil? || value == ''
      end

      def _debug(msg)
        MyRailsHelpers::ParamsHelper.debug(msg)
      end
    end
  end
end
