module MyRailsHelpers
  module ParamsHelper
    module Store

      attr_accessor :backend

      class TestBackend
        def get(key); nil end
        def set(key, val); nil end
        def reset(key); nil end
      end

      class AptRedis
        def initialize
          @_redis ||= Resque.redis
        end

        def reset(key)
          @_redis.del(key)
        end

        def set(key, object)
          @_redis.set(key, Marshal.dump(object)) unless object.blank?
        rescue
          reset(key)
        end

        def get(key)
          Marshal.load(@_redis.get(key)) unless @_redis.get(key).blank?
        rescue
          reset(key)
        end
      end

      # Gets the params from memory loads them and then saves them back
      def persist(user: nil, namespace: nil)
        params = load(self.backend.get(_key(user, namespace)))

        if !params.nil? && !params.empty?
          _debug "Saving params #{params.inspect}"
          self.backend.set(_key(user, namespace), params)
        end
      end

    private
        # This comes from memory for persistence
      def load(stored_params)

        stored_params ||= {}

        _debug "Params from memory: #{stored_params.inspect}"
        _debug "Original params: #{@params}"

        if use_stored?
          _debug "No filter - placing remembered params from memory"
          @params = stored_params
        end

        _debug "end result: #{@params.inspect}"

        @params
      end

      def use_stored?
        @params.blank?
      end

      def _key(user, namespace)
        raise 'No user supplied' unless user
        "#{user.class}-#{user.id}"
      end
    end
  end
end
