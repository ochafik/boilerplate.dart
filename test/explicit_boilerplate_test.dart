import 'package:unittest/unittest.dart';
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

class Baz {
  final int i;
  Baz(this.i);
}

class Bam extends Baz with ExplicitBoilerplate {
  Bam(int i): super(i);
  @override get fields => { "i": i };
  @override get className => "Bam";
}

class Empty extends ExplicitBoilerplate {
  @override get fields => { };
  @override get className => "Empty";
}


class ColsBase {
  final List<int> intList;
  final Map map;
  ColsBase(this.intList, this.map);
}

class NotWithBoilerplate {}

class ColsChild extends ColsBase with ExplicitBoilerplate {
  final Set<String> stringSet;
  final Iterable<num> doubleIterable;
  final NotWithBoilerplate pain;
  ColsChild(List<int> intList, Map map, this.stringSet, this.doubleIterable, this.pain): super(intList, map);
  @override get fields => { "intList": intList, "map": map, "stringSet": stringSet, "doubleIterable": doubleIterable, "pain": pain };
  @override get className => "ColsChild";
}

isDifferent(other) => predicate((x) => x != other, "is different from " + other.toString());

void main() {
  group("ExplicitBoilerplate", () {
    group("toString()", () {
      test("gives expected string on simple classes", () {
        expect(new Bar(1).toString(), equals("Bar { i: 1 }"));
        expect(new Foo(1, 2, "3").toString(), equals("Foo { i: 1, j: 2, s: 3 }"));
        expect(new Bam(1).toString(), equals("Bam { i: 1 }"));
        expect(new Empty().toString(), equals("Empty {  }"));
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
    });
  });
}
