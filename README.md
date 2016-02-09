# Noaidi

This is a proof-of-concept gem for creating focused, erlang-inspired modules, with pattern matching and (optional) return value contracts. Note that if you want more sophisticated solution, you might have a look at [contracts.ruby](https://github.com/egonSchiele/contracts.ruby) gem.

## Usage

A classical example of using pattern amtchi is a naive recursive Fibonacci implementation. Here's how it looks with `noaidi`:

```ruby
require 'noaidi'

naive = Noaidi.module do
  fun :fib, [0] { 0 }
  fun :fib, [1] { 1 }
  fun :fib, [Integer] do |n|
    fib(n - 1) + fib(n - 2)
  end
end

puts naive.fib(5)
puts naive.fib(15)
```

As you see, the core concept is a `fun`. You create is using DSL inside a block passed to `Noaidi.module`. First parameter is a fun name, second is array of argument contracts. It is followed by a block. Of course, you can reference `fun`s from the same module in other funs.

Argument contracts are realized using `===` operator (just like with `case` statements) for now. This might be extended to support more expressive cases, but works for now. It means that you can use, for example:

* Classes – to indicate that the argument has to be an instance of this class or its subclass
* Values – so that the argument has to be exactly the same
* Ranges – to have the argument included in the boundaries of a range

You can use `any` keyword if you don't want to specify constraint on the argument:

```ruby
fun :whatever, [any, Integer] { |a, i| a.to_s * i }
```

### Return value contracts

Optionally you can defina a contract for return value. This means that you may be safely reason (to some extent) about the value which is returned by `fun`. To do that, follow the `fun` declaration with `.returns` method:

```ruby
contracted = Noaidi.module do
  fun :id_for_numbers, [Object] do |x|
    x
  end.returns(Integer)
end

contracted.id_for_numbers(1)
#=> 1
contracted.id_for_numbers("lorem ipsum")
#=> raises Noaidi::ReturnContractViolation
```

If you want even more specific cases, you might extend return contract with a lambda:

```ruby
contracted = Noaidi.module do
  fun :id_for_small_numbers, [Object] do |x|
    x
  end.returns(Integer, ->(x) { x < 10 })
end

contracted.id_for_small_numbers(1)
#=> 1
contracted.id_for_small_numbers(12)
#=> raises Noaidi::ReturnContractViolation
```

### Immutability

It's not easy to enforce immutability in language like Ruby and I won't try too hard to do it. However, `fun`s are frozen, which means that you can change it after it has been moduled. It also means that **you can't use instance variables** in `fun`s (that's intentional, as using them could possibly yield unexpected results). Of course, I bet there are some trick with which you can overcome this, but having to use them should discourage you enough.

### Default arguments

Default arguments for `fun`s are not supported and won't be supported. This is by design. If you want to have default arguments, use constructs known in other languages, i.e.

```ruby
fun :mult, [Integer, Integer] {|x,y| x*y }
fun :mult, [Integer] {|x| mult(x, 1) }
```

## Testing

Run `rake spec`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katafrakt/noaidi.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
