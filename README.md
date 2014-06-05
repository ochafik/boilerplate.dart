No-brainer Dart helpers for boilerplate methods implementation ([get it with pub](http://pub.dartlang.org/packages/boilerplate)).

    import 'package:boilerplate/boilerplate.dart';
    class Foo extends Boilerplate {
      final int i;             // .toString, .hashCode, .operator==
      final List<int> js;      // and copy({ i, js })
      Foo(this.i, this.js);    // with no extra effort.
    }
    var foo = new Foo(1, [2, 3]);
    assert(foo == new Foo(1, [2, 3]));
    print(foo);                 // "Foo { i: 1, js: [2, 3] }"
    print(foo.copy(i: js: [])); // "Foo { i: 1, js: [] }"

These methods bring Dart classes closer to Scala case classes (although immutability is not enforced).

# What is Boilerplate?

`Boilerplate` saves you those cumbersome and error-prone [hashCode](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-core.Object#id_hashCode), [operator==](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-core.Object#id_==) and [toString](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-core.Object#id_toString) methods in Dart.

It implements them by passing the *public fields* values through to [collection/equality.dart](https://github.com/dart-lang/bleeding_edge/tree/master/dart/pkg/collection), which performs the equality / hashing / toString for us.

There's two variants:
* `Boilerplate` uses mirrors to get the list of fields and their values.

  This means you need to preserve metadata of your class with `@MirrorsUsed` annotations (see example below).

  `Boilerplate` also adds a `copy` method [as in Scala case classes](http://www.scala-lang.org/old/node/2075), which creates a copy with the default constructor using the same field values as the original, except for the provided named argument overrides.

* `ExplicitBoilerplate` requires you to specify the fields and class name explicitly. It doesn't use mirrors but some boilerplate is needed (although smaller than the methods it helps implement).

# Limitations

These two classes are not designed for every possible use case, as they have the following limitations:
* Equality only holds between instances of the exact same runtime type.
* `Boilerplate` Only uses public fields by default (but you can still override `get fields`),
* No special handling of reference cycles: user must avoid them responsibly,
* Not optimized for speed (but some care is taken to cache costly mirror results). If you need fast boilerplate methods, please consider implementing them with [quiver-dart](https://github.com/google/quiver-dart).
* Subsequent calls of hashCode on an object with mutable fields may yield different values (well, just as in Java),

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

    var bar = new Bar(1);
    var foo = new Foo(1, 2, "3");
    print(bar);  // "Bar { i: 1 }"
    print(foo);  // "Foo { i: 1, j: 2, s: 3 }"

    assert(bar == new Bar(1));
    assert(bar != new Bar(2));

    assert(bar == bar.copy());
    assert(new Bar(2) == bar.copy(i: 2));

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

Note that `Boilerplate` and `ExplicitBoileplate` can be safely mixed in at any level of the class hierarchy:

     class A extends Boilerplate {}
     class B extends A with Boilerplate {}

# TODO

* Watch for more suggestions on [Issue 19181](https://code.google.com/p/dart/issues/detail?id=19181),

# Changelog

* Version 0.1.1:
  * Added Boilerplate.copy that mimics [Scala case classes's copy method](http://www.scala-lang.org/old/node/2075).
* Version 0.1.0:
  * Initial Boilerplate and ExplicitBoilerplate with hashCode, operator==, toString. 
