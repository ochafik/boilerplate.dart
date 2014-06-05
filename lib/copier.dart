part of boilerplate.mirrors;

/// Error thrown when [Boilerplate.copy] fails.
class CopyError extends Error {
  String message;
  CopyError(this.message);
  String toString() => "Copy error: " + message;
}

/// Method-like copier object, that takes named arguments that match constructor params.
class _Copier extends Function {
  final dynamic original;
  final _TypeConstructorMetadata metadata;
  
  _Copier(this.original, this.metadata);
  
  /**
   * This class does not implement [Function.call] so as to capture named arguments of its
   * invocation. The beauty of extending Function is that unknown named arguments of the call
   * method don't give us warnings.
   */
  dynamic noSuchMethod(Invocation i) {
    if (MirrorSystem.getName(i.memberName) != "call") {
      throw new NoSuchMethodError(this, i.memberName, i.positionalArguments, i.namedArguments);
    }
    if (!i.positionalArguments.isEmpty) {
      throw new CopyError("Method requires named parameters only.");
    }
    InstanceMirror originalMirror = reflect(original);  
    _InvocationBuilder builder = new _InvocationBuilder();
    
    int usedArgumentCount = 0;
    for (_InvocationUpdater updater in metadata.invocationUpdaters) {
      if (updater(originalMirror, i, builder)) {
        usedArgumentCount++;
      }
    }
    if (usedArgumentCount != i.namedArguments.length) {
      Set<Symbol> unusedNamedArguments =
          new Set.from(i.namedArguments.keys)
              ..removeAll(metadata.paramNames);
      throw new CopyError("Named arguments don't match any argument in the constructor: "
          + unusedNamedArguments.toList()
              .map((s) => MirrorSystem.getName(s))
              .join(", "));
    }
    
    return metadata.classMirror
        .newInstance(metadata.constructorMirror.constructorName,
            builder.positionalArguments, builder.namedArguments)
        .reflectee;
  }
}