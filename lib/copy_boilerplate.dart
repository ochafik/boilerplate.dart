library copy_boilerplate;

@MirrorsUsed(symbols: const["copy", "call"], override: "*")
import 'dart:mirrors';

/**
 * Mixin that implements a `copy` method that can be used to clone instances using
 * mirrors.
 * 
 * Optional named params allow to change values: `foo.copy(bar: false)`.
 */ 
class CopyBoilerplate {
  static Map<Type, _CopyTypeMetadata> _cachedCloneTypeMetadata = {};

  static _CopyTypeMetadata _getCopyTypeMetadata(Type type) {
    var metadata = _cachedCloneTypeMetadata[type];
    if (metadata == null) {
      metadata = new _CopyTypeMetadata(type);
      _cachedCloneTypeMetadata[type] = metadata;
    }
    return metadata;
  }

  Function get copy => new _Copier(this, _getCopyTypeMetadata(runtimeType));
}

class _InvocationBuilder {
  List positionalArguments = [];
  Map namedArguments = {};
}

typedef void _InvocationUpdater(InstanceMirror originalMirror, Invocation invocation, _InvocationBuilder builder);

class _CopyTypeMetadata {
  ClassMirror classMirror;
  MethodMirror constructorMirror;
  
  List<_InvocationUpdater> invocationUpdaters = [];
  
  _CopyTypeMetadata(Type type) {
    classMirror =  reflectClass(type);

    var constructors = classMirror.declarations.values
      .where((d) => (d is MethodMirror) && (d.isConstructor || d.isConstConstructor));
    if (constructors.length != 1) {
      throw new _CopyError("Expected only one constructor, found"); 
    }
    constructorMirror = constructors.single;

    for (ParameterMirror param in constructorMirror.parameters) {
      Symbol paramName = param.simpleName;
      invocationUpdaters.add((originalMirror, invocation, builder) {
        dynamic value; 
        if (invocation.namedArguments.containsKey(paramName)) {
          value = invocation.namedArguments[paramName];
        } else {
          value = originalMirror.getField(paramName).reflectee;
        }
        if (param.isNamed) {
          builder.namedArguments[paramName] = value;
        } else {
          builder.positionalArguments.add(value);
        }
      });
    }
  }
}

class _Copier extends Function {
  final dynamic original;
  final _CopyTypeMetadata metadata;
  
  _Copier(this.original, this.metadata);
  
  noSuchMethod(Invocation i) {
    assert(MirrorSystem.getName(i.memberName) == "call");
    assert(i.positionalArguments.isEmpty);
    InstanceMirror originalMirror = reflect(original);  
    _InvocationBuilder builder = new _InvocationBuilder();
    
    for (_InvocationUpdater updater in metadata.invocationUpdaters) {
      updater(originalMirror, i, builder);
    }
    
    return metadata.classMirror
        .newInstance(metadata.constructorMirror.constructorName,
            builder.positionalArguments, builder.namedArguments)
        .reflectee;
  }
}

class _CopyError extends Error {
  String message;
  _CopyError(this.message);
  String toString() => "Copy error: " + message;
}
