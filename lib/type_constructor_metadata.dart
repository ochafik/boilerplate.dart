part of boilerplate.mirrors;

class _InvocationBuilder {
  List positionalArguments = [];
  Map namedArguments = {};
}

typedef bool _InvocationUpdater(InstanceMirror originalMirror, Invocation invocation, _InvocationBuilder builder);

class _TypeConstructorMetadata {
  ClassMirror classMirror;
  MethodMirror constructorMirror;
  Set<Symbol> paramNames = new Set();
  static const defaultConstructorSymbol = const Symbol("");
  
  /// List of updaters that need to be called to fill in the constructor invocation.
  List<_InvocationUpdater> invocationUpdaters = [];
  
  _TypeConstructorMetadata(ClassMirror this.classMirror) {

    var constructors = classMirror.declarations.values
      .where((d) => (d is MethodMirror) && (d.isConstructor || d.isConstConstructor));
    
    constructorMirror = constructors.firstWhere((d) => d.constructorName == defaultConstructorSymbol);
    if (constructorMirror == null) {
      String className = MirrorSystem.getName(classMirror.qualifiedName);
      throw new CopyError("No default constructor found in $className.");
    }
        
    for (ParameterMirror param in constructorMirror.parameters) {
      Symbol paramName = param.simpleName;
      paramNames.add(paramName);
      invocationUpdaters.add((originalMirror, invocation, builder) {
        dynamic value;
        bool usedSomeArgument = false;
        if (invocation.namedArguments.containsKey(paramName)) {
          value = invocation.namedArguments[paramName];
          usedSomeArgument = true;
        } else {
          value = originalMirror.getField(paramName).reflectee;
        }
        if (param.isNamed) {
          builder.namedArguments[paramName] = value;
        } else {
          builder.positionalArguments.add(value);
        }
        return usedSomeArgument;
      });
    }
  }
}
