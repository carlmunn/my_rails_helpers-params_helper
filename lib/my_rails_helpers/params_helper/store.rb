module MyRailsHelpers
  module ParamsHelper
    module Store

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

      def persist(user: nil, namespace: nil)
        puts "[DEPRECATED] ParamsHelper#persist"
        save(user: user, namespace: namespace)
      end

      # Gets the params from memory loads them and then saves them back
      def save(user: nil, namespace: nil)
        
        params = load(backend.get(_key(user, namespace)))

        if !params.nil? && !params.empty?
          _debug "Saving params #{_key(user, namespace)} = #{params}"
          backend.set(_key(user, namespace), params)
        end
      end

    private
      def backend
        @backend ||= AptRedis.new
      end

      # This comes from memory for persistence
      def load(stored_params)

        stored_params ||= {}

        _debug "Params from memory: #{stored_params}"
        _debug "Original params: #{@params}"

        if use_stored?
          _debug "No filter - placing remembered params from memory"

          stored_params.each do |k, v|
            _debug "Inserting #{k}"

            if opt = get(k)
              opt.value = v
            end
          end

          @params.merge!(stored_params)
        end

        _debug "end result: #{@params.inspect}"

        @params
      end

      def use_stored?
        @params.blank?
      end

      def _key(user, namespace)
        raise 'No user supplied' unless user
        [namespace, user.class, user.id].compact.join('-')
      end
    end
  end
end
