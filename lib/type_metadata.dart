part of boilerplate.mirrors;

class _TypeMetadataCache {

  /// Cached type reflectors.
  static Map<Type, _TypeMetadata> _cachedTypeReflectors = {};

  /// Get or create a cached reflector for the given type.
  static _TypeMetadata getMetadata(Type type) {
    _TypeMetadata b = _cachedTypeReflectors[type];
    if (b == null) {
      b = new _TypeMetadata(type);
      _cachedTypeReflectors[type] = b;
    }
    return b;
  }
}

typedef dynamic _FieldGetter(dynamic instance);

/**
 * Type-specific reflector able to extract the list of field names / value and
 * the class name using mirrors.
 */
class _TypeMetadata {
  
  /// Mirror of the Type which this metadata is about.
  
  ClassMirror typeMirror;

  /// Map of field name to field getter.
  Map<String, _FieldGetter> _fieldGetters;

  /// Cached value of the simple class name.
  String _className;
  
  /// Cached value of the constructor metadata.
  _TypeConstructorMetadata _constructorMetadata;

  /// Build a type metadata.
  _TypeMetadata(Type type) {
    typeMirror = reflectClass(type);
  }

  /// Get the map of field name to field getter (functions of instance to field value).
  Map<String, _FieldGetter> get fieldGetters {
    if (_fieldGetters == null) {
      _fieldGetters = {};
      typeMirror.instanceMembers.forEach((fieldName, declaration) {
        if (declaration.isGetter && !declaration.isPrivate) {
          String n = MirrorSystem.getName(fieldName);
          switch (n) {
            case "class":
            case "className":
            case "copy":
            case "fields":
            case "hashCode":
            case "runtimeType":
              // Skip those getters.
              break;
            default:
              _fieldGetters[n] = (dynamic instance) {
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
   * Get the simple name of the class.
   */
  String get className {
    if (_className == null) {
      _className = MirrorSystem.getName(typeMirror.simpleName);
    }
    return _className;
  }

  /**
   * Get the constructor metadata.
   */
  _TypeConstructorMetadata get constructorMetadata {
    if (_constructorMetadata == null) {
      _constructorMetadata = new _TypeConstructorMetadata(typeMirror);
    }
    return _constructorMetadata;
  }
}