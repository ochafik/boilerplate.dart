part of boilerplate.mirrors;

/// Some Mirror-related utilities used in the library.
class _MirrorUtils {

  /// Get public fields using mirrors.
  static Map<String, dynamic> reflectFields(dynamic instance) {
    var metadata = _TypeMetadataCache.getMetadata(instance.runtimeType);
    Map<String, dynamic> fields = {};
    metadata.fieldGetters.forEach((n, getter) {
      fields[n] = getter(instance);
    });
    return fields;
  }
  
  /// Get the simple class name using mirrors.
  static String reflectClassName(dynamic instance) {
    var metadata = _TypeMetadataCache.getMetadata(instance.runtimeType);
    return metadata.className;
  }
  
  /// Copy using default constructor.
  static Function copy(dynamic instance) {
    var metadata = _TypeMetadataCache.getMetadata(instance.runtimeType);
    return new _Copier(instance, metadata.constructorMetadata);
  }
}