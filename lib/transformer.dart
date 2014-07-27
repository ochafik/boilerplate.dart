library boilerplate.transformer;

import 'dart:async';
import 'dart:io';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:source_maps/printer.dart';
import 'package:source_maps/refactor.dart';

class BoilerplateInserter extends ResolverTransformer {
  final BarbackSettings _settings;

  BoilerplateInserter.asPlugin(this._settings) {
    var dartSdkDir = Platform.environment["DART_SDK"];
//    var dartSdkDir = "/Users/ochafik/bin/dart-1.5.3/dart-sdk";
    assert(dartSdkDir != null);
    resolvers = new Resolvers(dartSdkDir);
  }

  @override
  String get allowedExtensions => ".dart";

  @override
  applyResolver(Transform transform, Resolver resolver) {
    var id = transform.primaryInput.id;
    for (LibraryElement lib in resolver.libraries) {
      for (CompilationUnitElement unit in lib.units) {
        // Only process the primary asset.
        if (id == resolver.getSourceAssetId(unit)) {
          TextEditTransaction tr = resolver.createTextEditTransaction(unit);
          if (tr != null) {
            for (ClassElement cls in unit.types.reversed) {
              if (cls.allSupertypes.any((it) => it.name == "Boilerplate")) {
                var offset = cls.node.leftBracket.offset + 1;
                var fieldNames = cls.fields.map((f) => f.name).where((String n) => !n.startsWith('_'));
                var codegen = [];
                if (!cls.methods.any((m) => m.isOperator && m.name == "==")) {
                  codegen.add('''
                    @override bool operator==(other) =>
                        (other is ${cls.name}) &&
                        ${fieldNames.map((n) => 'BoilerplateUtils.equal($n, other.$n)').join(' && ')};
                  ''');
                }
                if (!cls.methods.any((m) => m.name == "toString")) {
                  codegen.add('''
                    @override String toString() => 
                        "${cls.name} { ${fieldNames.map((n) => '$n: \$$n').join(', ')} }";
                  ''');
                }
                if (!cls.accessors.any((a) => a.isGetter && a.variable.name == "hashCode")) {
                  codegen.add('''
                    @override int get hashCode =>
                        BoilerplateUtils.computeHashCode([${fieldNames.join(', ')}]);
                  ''');
                }
                var replace = codegen.join("\n");
//                replace = '/* boilerplate */\n' + replace.replaceAll(new RegExp("                ", multiLine: true), '  ');
                replace = replace.replaceAll(new RegExp(r'\s+', multiLine: true), ' ');
                tr.edit(offset, offset, replace);
              }
            }
            if (tr.hasEdits) {
              NestedPrinter printer = tr.commit();
              var url = id.path.startsWith('lib/') ?
                  'package:${id.package}/${id.path.substring(4)}' : id.path;
              printer.build(url);
              transform.addOutput(new Asset.fromString(id, printer.text));
              /// TODO(ochafik): test source maps.
              transform.addOutput(new Asset.fromString(id.addExtension('.map'), printer.map));
            }
          }
        }
      }
    }
    return new Future.value();
  }

  @override
  Future<bool> isPrimary(AssetId id) =>
      new Future.value(id.extension == ".dart");

  @override
  Future<bool> shouldApplyResolver(Asset asset) =>
      new Future.value(true);
}