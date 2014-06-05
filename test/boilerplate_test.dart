@MirrorsUsed(targets: const[Foo, Bar], override: "*")
import 'dart:mirrors';
import 'package:unittest/unittest.dart';
import 'package:boilerplate/boilerplate.dart';

class Not extends Matcher {
  final Matcher negated;
  const Not(this.negated);
  
  bool matches(item, Map matchState) => !negated.matches(item,  matchState);
  Description describe(Description description) {
    return negated.describe(description.add('not '));
  }
}

class Bar extends Boilerplate {
  final int i;
  Bar(this.i);
}

class Foo extends Bar {
  final int j;
  final String s;
  Foo(int i, this.j, this.s): super(i);
}

class Baz {
  final int i;
  Baz(this.i);
}

class Bam extends Baz with Boilerplate {
  Bam(int i): super(i);
}

class Empty extends Boilerplate {}

class ColsBase {
  final List<int> intList;
  final Map map;
  ColsBase(this.intList, this.map);
}

class NotWithBoilerplate {}

class ColsChild extends ColsBase with Boilerplate {
  final Set<String> stringSet;
  final Iterable<num> doubleIterable;
  final NotWithBoilerplate pain;
  ColsChild(List<int> intList, Map map, this.stringSet, this.doubleIterable, this.pain): super(intList, map);
}

isDifferent(other) => predicate((x) => x != other, "is different from " + other.toString());

class A extends Boilerplate {
  int i;
  int j;
  A({this.i, this.j});
}

class B extends Boilerplate {
  int i;
  int j;
  B(this.i, {this.j});
}

class C extends Boilerplate {
  int i;
  int j;
  C(this.i, this.j);
}

class D extends Boilerplate {
  int i;
  int j;
  D();
}

class X extends Boilerplate {
  int x;
}

void main() {
  group("Boilerplate", () {
    group("toString()", () {
      test("gives expected string on simple classes", () {
        expect(new Bar(1).toString(), equals("Bar { i: 1 }"));
        expect(new Foo(1, 2, "3").toString(), equals("Foo { i: 1, j: 2, s: 3 }"));
        expect(new Bam(1).toString(), equals("Bam { i: 1 }"));
        expect(new Empty().toString(), equals("Empty {  }"));
      });
      test("gives expected string on class with collections", () {
        var c = new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null);
        expect(c.toString(), equals("ColsChild { intList: [1, 2], map: {three: 4, five: [6, 7]}, stringSet: {8, 9}, doubleIterable: (0, 1), pain: null }"));
      });
    });
    group("hashCode", () {
      test("gives same value for same constructor params on simple classes", () {
        expect(new Bar(1).hashCode, equals(new Bar(1).hashCode));
        expect(new Foo(1, 2, "3").hashCode, equals(new Foo(1, 2, "3").hashCode));
        expect(new Bam(1).hashCode, equals(new Bam(1).hashCode));
        expect(new Empty().hashCode, equals(new Empty().hashCode));
      });
      test("gives different values for different constructor params on simple classes", () {
        expect(new Bar(1).hashCode, isDifferent(new Bar(2).hashCode));
        expect(new Foo(1, 2, "3").hashCode, isDifferent(new Foo(2, 2, "3").hashCode));
        expect(new Foo(1, 2, "3").hashCode, isDifferent(new Foo(1, 3, "3").hashCode));
        expect(new Foo(1, 2, "3").hashCode, isDifferent(new Foo(1, 2, "4").hashCode));
        expect(new Bam(1).hashCode, isDifferent(new Bam(2).hashCode));
      });
      test("gives same value for same constructor params on class with collections", () {
        expect(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode,
            equals(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode));
      });
      test("gives different values for different constructor params on class with collections", () {
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode,
            isDifferent(new ColsChild([1, 3], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode,
            isDifferent(new ColsChild([1, 2], {"three": 5, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode,
            isDifferent(new ColsChild([1, 2], {"three": 4, "five": [7, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["9"]),      new Iterable.generate(2, (i) => i), null).hashCode,
            isDifferent(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(3, (i) => i), null).hashCode));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null).hashCode,
            isDifferent(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => 0), null).hashCode));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), new NotWithBoilerplate()).hashCode,
            isDifferent(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), new NotWithBoilerplate()).hashCode));
      });
    });
    group("operator==", () {
      test("equals other instance with same constructor params on simple classes", () {
        expect(new Bar(1), equals(new Bar(1)));
        expect(new Foo(1, 2, "3"), equals(new Foo(1, 2, "3")));
        expect(new Bam(1), equals(new Bam(1)));
        expect(new Empty(), equals(new Empty()));
      });
      test("does not equal other instance with same constructor params on simple classes", () {
        expect(new Bar(1), isDifferent(new Bar(2)));
        expect(new Foo(1, 2, "3"), isDifferent(new Foo(2, 2, "3")));
        expect(new Foo(1, 2, "3"), isDifferent(new Foo(1, 3, "3")));
        expect(new Foo(1, 2, "3"), isDifferent(new Foo(1, 2, "4")));
        expect(new Bam(1), isDifferent(new Bam(2)));
      });
      test("equals other instance with same constructor params on class with collections", () {
        expect(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null),
            equals(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null)));
      });
      test("does not equal other instance with same constructor params on class with collections", () {
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null),
            isDifferent(new ColsChild([1, 3], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null)));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null),
            isDifferent(new ColsChild([1, 2], {"three": 5, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null)));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null),
            isDifferent(new ColsChild([1, 2], {"three": 4, "five": [7, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null)));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["9"]),      new Iterable.generate(2, (i) => i), null),
            isDifferent(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(3, (i) => i), null)));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null),
            isDifferent(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => 0), null)));
        expect(         new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), new NotWithBoilerplate()),
            isDifferent(new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), new NotWithBoilerplate())));
      });
    });

    group("copy", () {
      test("returns distinct by equal instance", () {
        var original = new Bar(1);
        var copy = original.copy();
        expect(original, equals(copy));
        expect(original, new Not(same(copy)));
      });
      test("returns expected copy", () {
        var original = new Bar(1);
        expect(new Bar(2), equals(original.copy(i: 2)));
        
        original = new Foo(1, 2, "3");
        expect(new Foo(10, 2, "3"), equals(original.copy(i: 10)));
        expect(new Foo(1, 20, "3"), equals(original.copy(j: 20)));
        expect(new Foo(1, 2, "30"), equals(original.copy(s: "30")));

        expect(new Foo(10, 20, "3"), equals(original.copy(i: 10, j: 20)));
        expect(new Foo(10, 2, "30"), equals(original.copy(i: 10, s: "30")));
        expect(new Foo(10, 20, "30"), equals(original.copy(i: 10, j: 20, s: "30")));
      });

      test("supports combinations of positional and named constructor arguments", () {
        var a = new A(i: 10, j: 20);
        expect(new A(i: 100, j: 20), equals(a.copy(i: 100)));
        expect(new A(i: 100, j: 30), equals(a.copy(i: 100, j: 30)));
          
        var b = new B(10, j: 20);
        expect(new B(100, j: 20), equals(b.copy(i: 100)));
        expect(new B(100, j: 30), equals(b.copy(i: 100, j: 30)));
      
        var c = new C(10, 20);
        expect(new C(100, 20), equals(c.copy(i: 100)));
        expect(new C(100, 30), equals(c.copy(i: 100, j: 30)));
      });

      test("throws on unknown named params", () {
        expect(() => new A().copy(x: 100), throwsA(new isInstanceOf<CopyError>()));
        expect(() => new D().copy(i: 100), throwsA(new isInstanceOf<CopyError>()));
      });

      test("throws when there's no default constructor", () {
        expect(() => new X().copy(x: 100), throwsA(new isInstanceOf<CopyError>()));
      });

      test("can't be misused", () {
        dynamic copy = new X().copy;
        expect(() => copy.blah, throwsA(new isInstanceOf<NoSuchMethodError>()));
      });
    });
  });
}
