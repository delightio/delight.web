module Mixins
  module Metric
    def metric_key key
      "#{self.class}_#{key}"
    end

    def update_metrics metrics
      unless metrics.nil?
        metrics.each_pair do |key, count|
          REDIS.zincrby metric_key(key), count, self.id
        end
      end
      true
    end

    def metrics key
      REDIS.zscore metric_key(key), self.id
    end
  end
end