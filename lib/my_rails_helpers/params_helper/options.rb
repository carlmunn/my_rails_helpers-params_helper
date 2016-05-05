module MyRailsHelpers
  module ParamsHelper

    class OptionBase

      attr_accessor :name

      def initialize(name, opts, params)
        @name   = name
        @opts   = opts
        @params = params
      end

      def self.parse(opts, params={})
        params ||= {}
        ary      = []

        opts.each do |name, data|

          param = if params.is_a?(Hash)
            result = params[name.to_sym]
            result = params[name.to_s] if result.nil?
            result
          else
            params
          end

          ary << if data.is_a?(Hash) && data[:val].is_a?(Hash)
            OptionCollection.new(name, data[:val], param)
          else
            Option.new(name, data, param)
          end

        end

        ary
      end
    end

    class Option < OptionBase

      def initialize(name, opts, param=nil)

        super

        if opts.is_a?(Hash)
          @default_value = opts[:val]
          @alias         = opts[:alias]
        else
          @default_value = opts
        end

        @fresh = param.nil?
        @param = param
        @param = {} if @param.nil?
      end

      # TODO:
      def alias
        @alias
      end

      def value(ignore: nil)
        val = param
        val = @default_value if val.nil?

        val = val.first if val.is_a?(Array)

        val = alias_lookup(val) unless ignore == :alias

        boolean_check(val)
      end

      # Is the value a default value that was set in configuration.
      #
      # Returns true if:
      # 1. The option wasn't set within the params; params where empty.
      # 2. The default value is the same as the passed param.
      # 3. The option is in the array of options and was meant to be or
      # 3. The option is not in the array and was meant to be that way.
      def default?
        if @default_value.is_a?(String) && @param.is_a?(String) && @default_value == @param
          _log "default: string == string"
          true
        elsif param_empty && @default_value == false
          _log "default: param_empty"
          true
        elsif @default_value == true && in_array?
          _log "default: @default_value == true && in_array?"
          true
        elsif @default_value == false && !in_array?
          _log "default: @default_value == false && !in_array?"
          true
        elsif @default_value == true
          _log "default: default = true"
          true
        elsif @default_value == value
          _log "default: default_value == value"
          true 
        else
          _log "default:else false (@default_value: #{@default_value}, in_array?: #{in_array?}, #{value})"
          false
        end
      end

      def on?
        if @fresh
          @default_value
        else
          in_array? || value == true
        end
      end

      def off?
        !on?
      end

      # This just mimics the OptionCollection's API
      def options
        [self]
      end

      def values
        @default_value
      end

    private

      # If the param passed is an array this checks if the option is within it.
      def in_array?
        @param.is_a?(Array) && (@param.include?(@name.to_sym) || @param.include?(@name.to_s))
      end

      def param
        param_empty ? nil : @param
      end

      def param_empty
        (@param.is_a?(Array) || @param.is_a?(Hash)) && @param.empty?
      end

      def alias_lookup(value)
        return value unless @alias
        result = (@alias[value.to_s] || @alias[value.to_sym])
        result ? result : value
      end

      def boolean_check(value)
        return true if ['true', '1'].include?(value)
        return false if ['false', '0'].include?(value)
        value
      end

      def _log(msg)
        #puts "\e[32m[D] #{msg}\e[0m"
      end
    end
 
    class OptionCollection < OptionBase

      attr_accessor :options, :name

      def initialize(name, opts, params)
        @fresh   = !!params.nil?
        @options = OptionBase.parse(opts, params)
        super
      end

      def find(name)
        @options.select {|opt| opt.name == name.to_sym || opt.name == name.to_s }.first
      end

      # Limited with what this can be used for, more a helper

      # 1. If fresh we'll use the defaults
      # 2. Flip for the UI
      def values(ignore: nil, flip: false)

        @options.select do |opt|

          result = (@fresh ? (opt.default? && opt.value) : opt.on?)
 
          result = false if (ignore == :defaults && opt.default?)

          flip ? !result : result

        end.map {|i| i.name.to_s }
      end
    end
  end
end
