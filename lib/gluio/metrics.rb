module GluIO
  module Metrics
    def self.time(name, &blk)
      start = Time.now.to_f
      res = yield
      finish = Time.now.to_f
      $stdout.puts("measure##{name}=#{((finish-start)*1000.0).to_i}ms")
      res
    end

    def self.count(name, count = 1)
      $stdout.puts("count##{name}=#{count}")
    end

    def self.sample(name, value)
      $stdout.puts("sample##{name}=#{value}")
    end
  end
end
