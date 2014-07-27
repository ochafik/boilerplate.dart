library boilerplate.mirrors;

@MirrorsUsed(
  symbols: const[
    "class",
    "className",
    "call",
    "copy",
    "fields",
    "hashCode",
    "runtimeType"],
  override: "*")
import 'dart:mirrors';

import 'boilerplate_utils.dart';
export 'boilerplate_utils.dart';

part 'copier.dart';
part 'mirror_utils.dart';
part 'type_constructor_metadata.dart';
part 'type_metadata.dart';

/**
 * Mixin that implements hashCode, operator== and toString based on public
 * instance fields, and provides a [copy] method that allows creating new
 * instances with the copy constructor of the class, keeping fields unchanged 
 * except for explicit named overrides.
 * 
 * Fields are typically discovered with mirrors, but can be declared
 * explicitly by overriding [fields].
 *
 * Likewise, class name (used by toString) is discovered with mirrors but can
 * be declared explicitly by overriding [className].
 *
 * Note that cyclic references are *not* taken care of by any of these methods:
 * it is the user code's responsibility to avoid them.
 *
 * Field values and hashCodes are not cached.
 *
 * For example:
 *
 *     @MirrorsUsed(targets: const[Foo, Bar], override: "*")
 *     import 'dart:mirrors';
 *
 *     class Bar extends Boilerplate {
 *       final int i;
 * 
 *       Bar(this.i);
 *     }
 *
 *     class Foo extends Bar {
 *       final int j;
 *       final String s;
 * 
 *       Foo(int i, this.j, this.s): super(i);
 *     }
 *
 *     var bar1 = new Bar(1);
 *     var foo124 = new Foo(1, 2, "3");
 *
 *     print(bar1);                      // "Bar { i: 1 }"
 *     print(foo123);                    // "Foo { i: 1, j: 2, s: 3 }"
 *     print(foo123.copy(i: 10, j: 0));  // "Foo { i: 10, j: 0, s: 3 }"
 *
 *     assert(new Bar(1) == new Bar(1));
 *     assert(new Bar(1) != new Bar(2));
 */
abstract class Boilerplate {

  /**
   * Get the map of field names to field values.
   *
   * Override this to avoid reflection when [hashCode] / operator== speed is a
   * concern, or when preserving mirror metadata is not an option (you
   * should also consider [ExplicitBoilerplate] in the latter case).
   *
   * For example:
   *
   *     class Foo extends Boilerplate {
   *       final int i;
   *       final String s;
   * 
   *       Foo(this.i, this.s);
   * 
   *       @override get fields => { "i": i, "s": s };
   *       @override get className => "Foo";
   *     }
   */
  Map<String, dynamic> get fields => _MirrorUtils.reflectFields(this);

  /**
   * Get the short name of the class for use in [toString].
   *
   * Override this to avoid reflection when [toString] speed is a
   * concern, or when preserving mirror metadata is not an option (you
   * should also consider [ExplicitBoilerplate] in the latter case).
   *
   * For example:
   *
   *     class Foo extends Boilerplate {
   *       final int i;
   *       final String s;
   * 
   *       Foo(this.i, this.s);
   * 
   *       @override get fields => { "i": i, "s": s };
   *       @override get className => "Foo";
   *     }
   */
  String get className => _MirrorUtils.reflectClassName(this);


  /// Computes a hashCode based on [fields] values.
  int get hashCode => BoilerplateUtils.computeHashCode(fields);

  /// Tests equality with exact [runtimeType] and deeply-equal [fields] values.
  bool operator==(other) => BoilerplateUtils.equal(this, other);

  /**
   * Basic toString implementation suitable mostly for debug purposes.
   *
   * This returns:
   *     "ClassName { field1: value1, field2: value2... }"
   *
   * Note that the class name may not be preserved by dart2js: to make sure it
   * is preserved, please have it preserved for mirrors with [MirrorsUsed]:
   *
   *     @MirrorsUsed(targets: const[Foo], override = "*")
   *     import 'dart:mirrors';
   *     import 'package:boilerplate/boilerplate.dart';
   *
   *     class Foo extends Boilerplate {
   *       final int i, j;
   *       Foo(this.i, this.j);
   *     }
   */
  String toString() => BoilerplateUtils.makeString(className, fields);

  /**
   * Acts as a copy method that takes named parameters that must match the
   * default constructor's parameter names.
   *
   * If there is no default constructor, this method will throw a [CopyError].
   *
   * If any named parameter is not in the list of positional or named
   * parameters of the unique constructor, this will throw a [CopyError].
   * 
   * This is a shallow copy: fields are not recursively cloned.
   * 
   * Example:
   * 
   *     import 'package:boilerplate/boilerplate.dart';
   * 
   *     class Foo extends Boilerplate {
   *       final int i, j;
   * 
   *       Foo(this.i, { this.j });
   *     }
   * 
   *     class Bar extends Boilerplate {
   *       final int i
   * 
   *     var foo = new Foo(1, j: 2);
   *     print(foo);             // "Foo { i: 1, j: 2 }"
   *     print(foo.copy(i: 10)); // "Foo { i: 10, j: 2 }"
   *     print(foo.copy(j: 20)); // "Foo { i: 1, j: 20 }"
   *     print(foo.copy(i: 10, j: 20));
   *                             // "Foo { i: 10, j: 20 }"
   * 
   *     assert(foo == foo.copy());
   *     assert(!identical(foo, foo.copy()));
   */
  Function get copy =>
    new _Copier(this, _TypeMetadataCache.getMetadata(runtimeType).constructorMetadata);
}
