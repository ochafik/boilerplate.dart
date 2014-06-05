library boilerplate.explicit;

import 'boilerplate_utils.dart';

/**
 * Mixin that implements hashCode, operator== and toString based on public
 * instance fields (explicit alternative to `Boilerplate` not using mirrors).
 *
 * Note that this mixin does not implement a `copy` method, which requires
 * mirrors.
 * 
 * [fields] and [className] getters need to be overridden.
 *
 * Cyclic references are *not* taken care of by any of the boilerplate methods:
 * it is the user code's responsibility to avoid them.
 *
 * Field values and [hashCode] are not cached.
 *
 * For example:
 *
 *     class Bar extends Boilerplate {
 *       final int i;
 * 
 *       Bar(this.i);
 * 
 *       @override get fields => { "i": i };
 *       @override get className => "Bar";
 *     }
 *
 *     class Foo extends Bar {
 *       final int j;
 *       final String s;
 * 
 *       Foo(int i, this.j, this.s): super(i);
 * 
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

  /// Get the map of field names to field values.
  Map<String, dynamic> get fields;

  /// Get the short name of the class for use in [toString].
  String get className;

  /// Computes a hashCode based on [fields] values.
  int get hashCode => BoilerplateUtils.computeHashCode(fields);

  /// Tests equality with exact [runtimeType] and deeply-equal [fields] values.
  bool operator==(other) => BoilerplateUtils.equal(this, other);

  /// Basic toString implementation suitable mostly for debug purposes.
  String toString() => BoilerplateUtils.makeString(className, fields);
}
