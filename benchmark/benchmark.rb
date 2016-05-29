require 'benchmark'
require 'noaidi'

module NoaidiBenchmark
  N = 100_000

  module_function

  def run
    values = (1..n).map{ |i| i.odd? ? [:odd, i] : [:even, i] }
    Benchmark.bmbm do |x|
      x.report("#{n} times without compile") { run_without_compile(values) }
      x.report("#{n} times with compile")    { run_with_compile(values) }
    end
  end

  def n
    n = ENV['N'].to_i
    n > 0 ? n : N
  end

  def run_without_compile(values)
    values.each do |val|
      Noaidi.match(val) do |m|
        m.(:odd, String) { raise StandardError('this should never be called') }
        m.(:odd, Integer) { |i| i }
        m.(:even, Integer) { |i| i + 1 }
      end
    end
  end

  def run_with_compile(values)
    match = Noaidi.compile_match do |m|
      m.(:odd, String) { raise StandardError('this should never be called') }
      m.(:odd, Integer) { |i| i }
      m.(:even, Integer) { |i| i + 1 }
    end

    values.each do |val|
      match.(val)
    end
  end
end
