library boilerplate;

@MirrorsUsed(
  symbols: const[
    "class",
    "className",
    "fields",
    "hashCode",
    "runtimeType"],
  override: "*")
import 'dart:mirrors';
import 'package:collection/equality.dart';

/**
 * Mixin that implements hashCode, operator== and toString based on public
 * instance fields.
 *
 * Fields are either discovered through reflection, or can be declared
 * explicitly by overriding `get fields` (return a map of field names to field
 * values).
 *
 * Class name (used by toString) is either discovered through reflection, or can
 * be declared explicitly by overriding `get className`.
 *
 * Cyclic references are *not* taken care of by any of the boilerplate methods:
 * it is the user code's responsibility to avoid them.
 *
 * Field values are not cached by any of the boilerplate method: after a field
 * is mutated, calls to hashCode / equals may yield different results.
 *
 * For example:
 *
 *     @MirrorsUsed(targets: const[Foo, Bar], override: "*")
 *     import 'dart:mirrors';
 *
 *     class Bar extends Boilerplate {
 *       final int i;
 *       Bar(this.i);
 *     }
 *
 *     /// `with Boilerplate` is optional here: it's inherited from Bar.
 *     class Foo extends Bar with Boilerplate {
 *       final int j;
 *       final String s;
 *       Foo(int i, this.j, this.s): super(i);
 *     }
 *
 *     print(new Bar(1));         // "Bar { i: 1 }"
 *     print(new Foo(1, 2, "3")); // "Foo { i: 1, j: 2, s: 3 }"
 *
 *     assert(new Bar(1) == new Bar(1));
 *     assert(new Bar(1) != new Bar(2));
 */
abstract class Boilerplate {
  /// Equality object used to compare fields.
  static const _equality = const DeepCollectionEquality();

  /// Cached type reflectors.
  static Map<Type, _TypeReflector> _cachedTypeReflectors = {};

  /// Get or create a cached reflector for the given type.
  static _TypeReflector _getTypeReflector(Type type) {
    _TypeReflector b = _cachedTypeReflectors[type];
    if (b == null) {
      b = new _TypeReflector(type);
      _cachedTypeReflectors[type] = b;
    }
    return b;
  }

  /**
   * Get the map of field names to field values.
   *
   * Override this to avoid reflection when hashCode / operator== speed is a
   * concern, or when preserving mirror metadata is not an option.
   *
   * For example:
   *
   *     class Foo extends Boilerplate {
   *       final int i;
   *       final String s;
   *       Foo(this.i, this.s);
   *       @override get fields => { "i": i, "s": s };
   *       @override get className => "Foo";
   *     }
   */
  Map<String, dynamic> get fields {
    Map<String, dynamic> fields = {};
    _getTypeReflector(runtimeType).fieldGetters.forEach((n, getter) {
      fields[n] = getter(this);
    });
    return fields;
  }

  /**
   * Get the short name of the class for use in [toString].
   *
   * Override this to avoid reflection when [toString] speed is a
   * concern, or when preserving mirror metadata is not an option.
   *
   * For example:
   *
   *     class Foo extends Boilerplate {
   *       final int i;
   *       final String s;
   *       Foo(this.i, this.s);
   *       @override get fields => { "i": i, "s": s };
   *       @override get className => "Foo";
   *     }
   */
  String get className {
    return _getTypeReflector(runtimeType).className;
  }

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
   *
   * Note that the class name may not be preserved by dart2js: to make sure it
   * is preserved, please have it preserved for mirrors with:
   *
   *     @MirrorsUsed(targets: const[ClassName], override = "*")
   *     import 'dart:mirrors';
   *     class ClassName extends Boilerplate {
   *       final int i, j;
   *       ClassName(this.i, this.j);
   *     }
   */
  String toString() {
    // Getting fields might be very costly: store it to a local var.
    var fields = this.fields;
    var body = fields.keys.map((n) => "$n: ${fields[n].toString()}").join(', ');
    return "$className { $body }";
  }
}

/**
 * Type-specific reflector able to extract the list of field names / value and
 * the class name using mirrors.
 */
class _TypeReflector {
  Type type;

  /**
   * Cache the map of fields getters retrieved using Mirrors when `get fields`
   * is not overridden.
   */
  Map<String, Function> _fieldGetters;

  /**
   * Cache the class name retrieved using Mirrors when `get className`
   * is not overridden.
   */
  String _className;

  _TypeReflector(this.type);

  /**
   * Get the map of field names to field values.
   */
  Map<String, dynamic> get fieldGetters {
    if (_fieldGetters == null) {
      _fieldGetters = {};
      reflectClass(type).instanceMembers.forEach((fieldName, declaration) {
        if (declaration.isGetter && !declaration.isPrivate) {
          String n = MirrorSystem.getName(fieldName);
          switch (n) {
            case "class":
            case "className":
            case "fields":
            case "hashCode":
            case "runtimeType":
              // Skip those getters.
              break;
            default:
              _fieldGetters[n] = (instance) {
                return reflect(instance).getField(fieldName).reflectee;
              };
              break;
          }
        }
      });
    }
    return _fieldGetters;
  }

  /**
   * Get the short name of the class for use in [toString].
   */
  String get className {
    if (_className == null) {
      _className = MirrorSystem.getName(reflectClass(type).simpleName);
    }
    return _className;
  }
}