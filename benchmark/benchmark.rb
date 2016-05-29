require 'benchmark'
require 'noaidi'

module NoaidiBenchmark
  N = 100_000

  module_function

  def run
    Benchmark.bmbm do |x|
      x.report("#{n} times without compile") { run_without_compile }
      x.report("#{n} times with compile")    { run_with_compile }
    end
  end

  def n
    n = ENV['N'].to_i
    n > 0 ? n : N
  end

  def run_without_compile
    (1..n).each do |val|
      Noaidi.match(val) do |m|
        m.(String) { raise StandardError('this should never be called') }
        m.(Integer) { |i| i }
      end
    end
  end

  def run_with_compile
    match = Noaidi.compile_match do |m|
      m.(String) { raise StandardError('this should never be called') }
      m.(Integer) { |i| i }
    end

    (1..n).each do |val|
      match.(val)
    end
  end
end
