library boilerplate.utils;

import 'package:collection/equality.dart';

/// Utilities used by both explicit and mirrors-based boilerplates.
class BoilerplateUtils {

  /// Equality object used to compare fields.
  static const _equality = const DeepCollectionEquality();
  
  static int computeHashCode(Map<String, dynamic> fields) {
    // Order of values matter: sort field names in case the map is unordered.
     // TODO(ochafik): Have _TypeReflector sort its field names and always
     //     assume "good" order (manual overrides of `get fields` would
     //     typically use map literals, which are ordered maps).
     List<String> names = new List.from(fields.keys)..sort();
     return _equality.hash(names.map((name) => _equality.hash(fields[name])));
  }
  
  /// Tests runtime types and same field values.
  static bool equal(a, b) {
      return (a.runtimeType == b.runtimeType)
          && _equality.equals(a.fields, b.fields);
  }
  
  static String makeString(String className, Map<String, dynamic> fields) {
    // Getting fields might be very costly: store it to a local var.
    var body = fields.keys.map((n) => "$n: ${fields[n].toString()}").join(', ');
    return "$className { $body }";
  }
}
