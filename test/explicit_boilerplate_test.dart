import 'package:unittest/unittest.dart';
import 'package:boilerplate/explicit_boilerplate.dart';

class ExplicitBar extends ExplicitBoilerplate {
  final int i;
  ExplicitBar(this.i);
  @override get fields => { "i": i };
  @override get className => "Bar";
}

class ExplicitFoo extends ExplicitBar {
  final int j;
  final String s;
  ExplicitFoo(int i, this.j, this.s): super(i);
  @override get fields => { "i": i, "j": j, "s": s };
  @override get className => "Foo";
}

class ExplicitBaz {
  final int i;
  ExplicitBaz(this.i);
}

class ExplicitBam extends ExplicitBaz with ExplicitBoilerplate {
  ExplicitBam(int i): super(i);
  @override get fields => { "i": i };
  @override get className => "Bam";
}

class ExplicitEmpty extends ExplicitBoilerplate {
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
        expect(new ExplicitBar(1).toString(), equals("Bar { i: 1 }"));
        expect(new ExplicitFoo(1, 2, "3").toString(), equals("Foo { i: 1, j: 2, s: 3 }"));
        expect(new ExplicitBam(1).toString(), equals("Bam { i: 1 }"));
        expect(new ExplicitEmpty().toString(), equals("Empty {  }"));
      });
    });
    group("hashCode", () {
      test("gives same value for same constructor params on simple classes", () {
        expect(new ExplicitBar(1).hashCode, equals(new ExplicitBar(1).hashCode));
        expect(new ExplicitFoo(1, 2, "3").hashCode, equals(new ExplicitFoo(1, 2, "3").hashCode));
        expect(new ExplicitBam(1).hashCode, equals(new ExplicitBam(1).hashCode));
        expect(new ExplicitEmpty().hashCode, equals(new ExplicitEmpty().hashCode));
      });
      test("gives different values for different constructor params on simple classes", () {
        expect(new ExplicitBar(1).hashCode, isDifferent(new ExplicitBar(2).hashCode));
        expect(new ExplicitFoo(1, 2, "3").hashCode, isDifferent(new ExplicitFoo(2, 2, "3").hashCode));
        expect(new ExplicitFoo(1, 2, "3").hashCode, isDifferent(new ExplicitFoo(1, 3, "3").hashCode));
        expect(new ExplicitFoo(1, 2, "3").hashCode, isDifferent(new ExplicitFoo(1, 2, "4").hashCode));
        expect(new ExplicitBam(1).hashCode, isDifferent(new ExplicitBam(2).hashCode));
      });
    });
    group("operator==", () {
      test("equals other instance with same constructor params on simple classes", () {
        expect(new ExplicitBar(1), equals(new ExplicitBar(1)));
        expect(new ExplicitFoo(1, 2, "3"), equals(new ExplicitFoo(1, 2, "3")));
        expect(new ExplicitBam(1), equals(new ExplicitBam(1)));
        expect(new ExplicitEmpty(), equals(new ExplicitEmpty()));
      });
      test("does not equal other instance with same constructor params on simple classes", () {
        expect(new ExplicitBar(1), isDifferent(new ExplicitBar(2)));
        expect(new ExplicitFoo(1, 2, "3"), isDifferent(new ExplicitFoo(2, 2, "3")));
        expect(new ExplicitFoo(1, 2, "3"), isDifferent(new ExplicitFoo(1, 3, "3")));
        expect(new ExplicitFoo(1, 2, "3"), isDifferent(new ExplicitFoo(1, 2, "4")));
        expect(new ExplicitBam(1), isDifferent(new ExplicitBam(2)));
      });
    });
  });
}
