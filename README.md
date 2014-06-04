No-brainer Dart helpers for boilerplate methods implementation (hashCode, operator==, toString).

# What is Boilerplate?

Boilerplate saves you those cumbersome and error-prone hashCode, operator== and toString methods in Dart.

It implements them by passing the public fields values through to [collection/equality.dart](https://github.com/dart-lang/bleeding_edge/tree/master/dart/pkg/collection), which performs the equality / hashing / toString for us.

Boilerplate can get the list of fields to different ways:
- Using mirrors; This means you need to preserve metadata of your class with `@MirrorsUsed` annotations.
- Using an explicit fields map getter: you don't need to preserve mirror metadata, but some boilerplate is needed (although smaller than the methods it helps implement). Please extend `ExplicitBoilerplate` instead of `Boilerplate` to avoid mirrors completely.

## Example with mirrors

    @MirrorsUsed(targets: const[Foo, Bar], override: "*")
    import 'dart:mirrors';
    import 'package:boilerplate/boilerplate.dart';

    class Bar extends Boilerplate {
      final int i;
      Bar(this.i);
    }

    class Foo extends Bar {
      final int j;
      final String s;
      Foo(int i, this.j, this.s): super(i);
    }

    print(new Bar(1));         // "Bar { i: 1 }"
    print(new Foo(1, 2, "3")); // "Foo { i: 1, j: 2, s: 3 }"

    assert(new Bar(1) == new Bar(1));
    assert(new Bar(1) != new Bar(2));

## Example without mirrors

    import 'package:boilerplate/explicit_boilerplate.dart';

    class Bar extends ExplicitBoilerplate {
      final int i;
      Bar(this.i);
      @override get fields => { "i": i };
      @override get className => "Bar";
    }

    class Foo extends Bar {
      final int j;
      final String s;
      Foo(int i, this.j, this.s): super(i);
      @override get fields => { "i": i, "j": j, "s": s };
      @override get className => "Foo";
    }

## Boilerplate can be mixed in

Note that Boilerplate can be safely mixed in at any level of the class hierarchy:

     class A extends Boilerplate {}
     class B extends A with Boilerplate {}

# Limitations

Boilerplate is not designed for every possible use case, as it has the following limitations:
- Only uses public fields by default,
- No special handling of reference cycles: user must avoid them responsibly,
- Not optimized for speed (but some care is taken to cache costly mirror results),
- Subsequent calls of hashCode on an object with mutable fields may yield different values (well, just as in Java),
- Requires mirrors (with proper MirrorsUsed annotation) *or* explicit definition of fields and className.
