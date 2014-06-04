library explicit_boilerplate;

import 'package:collection/equality.dart';

/**
 * Mixin that implements hashCode, operator== and toString based on public
 * instance fields (explicit alternative to [Boilerplate] using no mirrors at all).
 *
 * Fields need to be declared explicitly by overriding `get fields` (return a map of field names to field
 * values).
 *
 * Class name (used by toString) needs to be declared explicitly by overriding `get className`.
 *
 * Cyclic references are *not* taken care of by any of the boilerplate methods:
 * it is the user code's responsibility to avoid them.
 *
 * Field values are not cached by any of the boilerplate method: after a field
 * is mutated, calls to hashCode / equals may yield different results.
 *
 * For example:
 *
 *     class Bar extends Boilerplate {
 *       final int i;
 *       Bar(this.i);
 *       @override get fields => { "i": i };
 *       @override get className => "Bar";
 *     }
 *
 *     class Foo extends Bar {
 *       final int j;
 *       final String s;
 *       Foo(int i, this.j, this.s): super(i);
 *       @override get fields => { "i": i, "j": j, "s": s };
 *       @override get className => "Foo";
 *     }
 *
 *     print(new Bar(1));         // "Bar { i: 1 }"
 *     print(new Foo(1, 2, "3")); // "Foo { i: 1, j: 2, s: 3 }"
 *
 *     assert(new Bar(1) == new Bar(1));
 *     assert(new Bar(1) != new Bar(2));
 */
abstract class ExplicitBoilerplate {
  /// Equality object used to compare fields.
  static const _equality = const DeepCollectionEquality();

  /**
   * Get the map of field names to field values.
   */
  Map<String, dynamic> get fields;

  /**
   * Get the short name of the class for use in [toString].
   */
  String get className;

  /// Computes a hashCode based on `fields` values.
  int get hashCode {
    // Getting fields might be very costly: store it to a local var.
    var fields = this.fields;
    // Order of values matter: sort field names in case the map is unordered.
    // TODO(ochafik): Have _TypeReflector sort its field names and always
    //     assume "good" order (manual overrides of `get fields` would
    //     typically use map literals, which are ordered maps).
    List<String> names = new List.from(fields.keys)..sort();
    return _equality.hash(names.map((name) => _equality.hash(fields[name])));
  }

  /// Tests runtime types and same field values.
  bool operator==(other) {
    return (runtimeType == other.runtimeType)
        && _equality.equals(fields, other.fields);
  }

  /**
   * Basic toString implementation suitable mostly for debug purposes.
   *
   * This returns:
   *     "ClassName { field1: value1, field2: value2... }"
   */
  String toString() {
    // Getting fields might be very costly: store it to a local var.
    var fields = this.fields;
    var body = fields.keys.map((n) => "$n: ${fields[n].toString()}").join(', ');
    return "$className { $body }";
  }
}
