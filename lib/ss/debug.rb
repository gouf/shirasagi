# coding: utf-8
module SS::Debug
  class << self
    public

    def dump(data, lev = 1)
      s = []
      if data.is_a?(Array) || data.is_a?(Hash)
        s << dump_for_array_hash(data, lev)
      else
        s << "#{data} <#{data.class}>"
      end
      return s.join if lev > 1

      ::File.open("#{Rails.root}/log/dump.log", 'a') do |f|
        f.puts s.join.force_encoding('utf-8')
      end
    end

    def bm(n = 1, &block)
      require 'benchmark'
      time = Benchmark.realtime { n.times { yield } }
      dump "#{format('%.6f ms', time / n)} (#{format('%.3f ms', time)}/#{n})"
    end

    private

    def dump_for_array_hash(data, lev = 1)
      s = []
      s << "<#{data.class}>{"
      return s << '}' if data.size.zero?

      s << "\n"
      s << dump_for_array(data, lev) if data.is_a?(Array)
      s << dump_for_hash(data, lev) if data.is_a?(Hash)
      s << "#{'  ' * (lev - 1)}}"
    end

    def dump_for_array(data, lev)
      data.map.with_index.reduce([]) do |s, pair|
        v, k = pair
        s << "#{'  ' * lev}#{k} \t=> #{dump(v, lev + 1)}\n"
      end
    end

    def dump_for_hash(data, lev)
      data.map.with_index.reduce([]) do |s, pair|
        k, v = pair
        s << "#{'  ' * lev}#{k} \t=> #{dump(v, lev + 1)}\n"
      end
    end
  end
end
