# Noaidi

This is a proof-of-concept gem for creating focused modules with pattern matching support. At its root it was inspired by how Erlang does it, but later was refined using concepts from Elixir language.

Noaidi is a Saami name for a shaman. According to Wikipedia:

> A noaidi was a mediator between the human world and _saivo_, the underworld, for the least of community problems.

So, this Noaidi is a mediator between the functional world and Ruby world (which of those is _saivo_, I leave it to you).

There are some blog posts about it:
* [A quest for pattern-matching in Ruby](http://katafrakt.me/2016/02/13/quest-for-pattern-matching-in-ruby/) (now obsolete, but still tells some things about motivation)
* [Refactoring Rails with pattern-matching (Noaidi)](http://katafrakt.me/2016/05/24/refactoring-rails-with-noaidi/)

## Usage

A basic unit of this library is a module. Module should define some functions (called `fun`s) and be responsible for some part of the domain. A classic example is a naive recursive Fibonacci implementation. Here's how it looks with `Noaidi`:

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

As you see, the core concept is a `fun`. You create is using DSL inside a block passed to `Noaidi.module`. First parameter is a fun name, second is array of arguments pattern. It is followed by a block. Of course, you can reference `fun`s from the same module in other funs. If you call for example `fib(1)`, the first fun where arguments pattern matches the actual arguments is called (and in this case will return `1`).

### Pattern matching

You can leverage pattern matching in Noaidi with some choices. That basic match will use `===` operator (like `case`). This way, except for exact values, you can match on:

* Classes – to indicate that the argument has to be an instance of this class or its subclass
* Values – so that the argument has to be exactly the same
* Ranges – to have the argument included in the boundaries of a range

There are also some special patterns, that are handled differently:

**Hashes**: You can pass `{ status: :ok }` as a pattern and it will match all hashes that include value `:ok` under `:status` key. It does not matter what the rest of the keys are. As a values you can also use other pattern, i.e. `{ response: 500..599, headers: { language: 'fi' } }` will match all hashes with response between 500 and 599 and also having a `:headers` key, containing a hash having `'fi'` under `:language` key.

**Lambdas** provide basic guard possibilities. If the lambda evaluates to `true`, it is a match. For example:

```ruby
Stat = Noaidi.module do
  # Assuming array is already sorted

  fun :median, [->(array) { array.is_a?(Array) && array.length.even? }] do
    half = array.length/2
    (array[half] + array[half - 1]) / 2.0
  end

  fun :median, [Array] { array[array.length/2] }
end
```

You can use `any` keyword if you don't want to specify constraint on the argument:

```ruby
fun :whatever, [any, Integer] { |a, i| a.to_s * i }
```

### Argument relevance

```ruby
Noaidi.match open_file(path) do |m|
  m.(:ok, File)         {|file| process_file(file) },
  m.(:error, Exception) {|ex| handle_file_opening_exception(path, ex) }
end
```

If you look at the example above, you'll notice that even though the pattern consists of two elements, only one is passed to execution block. This is because of relevance checker. If you match against `:ok, File` you will always have `:ok` as the first argument, and therefore there's no point in passing it to the block.

The rule here is that if you match by value (usually symbols, strings, numbers), the pattern is irrelevant. In every other case, it is relevant and passed to the block.

### Immutability

It's not easy to enforce immutability in language like Ruby and I won't try too hard to do it. However, `fun`s are frozen, which means that you can change it after it has been moduled. It also means that **you can't use instance variables** in `fun`s (that's intentional, as using them could possibly yield unexpected results). Of course, I bet there are some trick with which you can overcome this, but having to use them should discourage you enough.

### Default arguments

Default arguments for `fun`s are not supported and won't be supported. This is by design. If you want to have default arguments, use constructs known in other languages, i.e.

```ruby
fun :mult, [Integer, Integer] {|x,y| x*y }
fun :mult, [Integer] {|x| mult(x, 1) }
```

### Using pattern matching outside modules

Sometimes you don want to write a module to use pattern matching. In those cases, use `Noaidi.match`.

```ruby
Noaidi.match save_post(@post) do |m|
    m.(:ok, Post) {|post| redirect_to post, notice: 'Post successfully created' },
    m.(:invalid, any) {|_validation_errors| render :new },
    m.(:error, StandardError) {|error| render :error_500, error: error }
end
```

If you care for performance, treat this pattern matching as RegEx, where initialization is a most expensive part. With that in mind, you can "compile" the match beforehand and only call subsequent values on compiled version. Use `Noaidi.compile_match` just like with an example above. The returned value will be a compiled matcher.

```ruby
matcher = Noaidi.compile_match do |m|
  ...
end

matcher.(value)
```

The benchmark comparing those two approaches on my laptop gives following results:

```
Rehearsal ----------------------------------------------------------------
100000 times without compile   1.190000   0.000000   1.190000 (  1.191833)
100000 times with compile      0.380000   0.000000   0.380000 (  0.388147)
------------------------------------------------------- total: 1.570000sec

                                   user     system      total        real
100000 times without compile   1.190000   0.000000   1.190000 (  1.184098)
100000 times with compile      0.390000   0.000000   0.390000 (  0.386056)
```

## Roadmap

Things I want to implement in the future:

* Private funs in module
* `_` operator that matches argument as irrelevant and does not pass it to execution block

## Testing

Run `rake spec`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katafrakt/noaidi.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
