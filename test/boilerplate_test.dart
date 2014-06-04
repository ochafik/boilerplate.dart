import 'package:unittest/unittest.dart';
import 'package:boilerplate/boilerplate.dart';


@MirrorsUsed(targets: const[MirrorFoo, MirrorBar], override: "*")
import 'dart:mirrors';

class MirrorBar extends Boilerplate {
  final int i;
  MirrorBar(this.i);
}

class MirrorFoo extends MirrorBar {
  final int j;
  final String s;
  MirrorFoo(int i, this.j, this.s): super(i);
}

class MirrorBaz {
  final int i;
  MirrorBaz(this.i);
}

class MirrorBam extends MirrorBaz with Boilerplate {
  MirrorBam(int i): super(i);
}

class MirrorEmpty extends Boilerplate {}

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

void main() {
  group("Boilerplate", () {
    group("toString()", () {
      test("gives expected string on simple classes", () {
        expect(new MirrorBar(1).toString(), equals("MirrorBar { i: 1 }"));
        expect(new MirrorFoo(1, 2, "3").toString(), equals("MirrorFoo { i: 1, j: 2, s: 3 }"));
        expect(new MirrorBam(1).toString(), equals("MirrorBam { i: 1 }"));
        expect(new MirrorEmpty().toString(), equals("MirrorEmpty {  }"));
      });
      test("gives expected string on class with collections", () {
        var c = new ColsChild([1, 2], {"three": 4, "five": [6, 7]}, new Set.from(["8", "9"]), new Iterable.generate(2, (i) => i), null);
        expect(c.toString(), equals("ColsChild { intList: [1, 2], map: {three: 4, five: [6, 7]}, stringSet: {8, 9}, doubleIterable: (0, 1), pain: null }"));
      });
    });
    group("hashCode", () {
      test("gives same value for same constructor params on simple classes", () {
        expect(new MirrorBar(1).hashCode, equals(new MirrorBar(1).hashCode));
        expect(new MirrorFoo(1, 2, "3").hashCode, equals(new MirrorFoo(1, 2, "3").hashCode));
        expect(new MirrorBam(1).hashCode, equals(new MirrorBam(1).hashCode));
        expect(new MirrorEmpty().hashCode, equals(new MirrorEmpty().hashCode));
      });
      test("gives different values for different constructor params on simple classes", () {
        expect(new MirrorBar(1).hashCode, isDifferent(new MirrorBar(2).hashCode));
        expect(new MirrorFoo(1, 2, "3").hashCode, isDifferent(new MirrorFoo(2, 2, "3").hashCode));
        expect(new MirrorFoo(1, 2, "3").hashCode, isDifferent(new MirrorFoo(1, 3, "3").hashCode));
        expect(new MirrorFoo(1, 2, "3").hashCode, isDifferent(new MirrorFoo(1, 2, "4").hashCode));
        expect(new MirrorBam(1).hashCode, isDifferent(new MirrorBam(2).hashCode));
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
        expect(new MirrorBar(1), equals(new MirrorBar(1)));
        expect(new MirrorFoo(1, 2, "3"), equals(new MirrorFoo(1, 2, "3")));
        expect(new MirrorBam(1), equals(new MirrorBam(1)));
        expect(new MirrorEmpty(), equals(new MirrorEmpty()));
      });
      test("does not equal other instance with same constructor params on simple classes", () {
        expect(new MirrorBar(1), isDifferent(new MirrorBar(2)));
        expect(new MirrorFoo(1, 2, "3"), isDifferent(new MirrorFoo(2, 2, "3")));
        expect(new MirrorFoo(1, 2, "3"), isDifferent(new MirrorFoo(1, 3, "3")));
        expect(new MirrorFoo(1, 2, "3"), isDifferent(new MirrorFoo(1, 2, "4")));
        expect(new MirrorBam(1), isDifferent(new MirrorBam(2)));
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
  });
}
