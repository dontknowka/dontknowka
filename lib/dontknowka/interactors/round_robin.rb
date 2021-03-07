require 'hanami/interactor'

require 'redis'

class RoundRobin
  include Hanami::Interactor

  expose :value

  def initialize(redis: Redis.new)
    @redis = redis
  end

  def call(key, max)
    @value = @redis.incr(key)
    if @value > max
      @redis.set(key, 1)
      @value = 1
    end
  end
end
