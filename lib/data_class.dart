import 'package:macros/macros.dart';


const _baseTypes = ['bool', 'double', 'int', 'num', 'String'];
const _collectionTypes = ['List'];

macro

class DataClass implements ClassDeclarationsMacro {
  const DataClass();

  @override
  void buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    final className = clazz.identifier.name;
    final fields = await builder.fieldsOf(clazz);


    var clazzFields = <_ClassField>[];

    for (final field in fields) {
      final fieldType = (field.type.code as NamedTypeAnnotationCode).name.name;

      var generics = <String>[];
      if (fieldType.isCollectionType) {
        generics.addAll((field.type.code as NamedTypeAnnotationCode)
            .typeArguments
            .map((e) => (e as NamedTypeAnnotationCode).name.name));
      }

      final clazzfield = _ClassField(field.identifier.name, fieldType, generics);
      clazzFields.add(clazzfield);
    }


    builder..declareInType(
        _buildNamedConstructor(className, clazzFields))..declareInType(
        _buildToString(className, clazzFields))..declareInType(_buildFromJson(
        className, clazzFields))..declareInType(
        _buildToJson(clazzFields))..declareInType(
        _buildCopyWith(
            className, clazzFields))..declareInType(
        _buildEquals(className, clazzFields))..declareInType(
        _buildHashCode(clazzFields));
  }

  DeclarationCode _buildNamedConstructor(String className,
      List<_ClassField> fields) {
    final code =
    '''
    const $className({
      ${fields.map((e) => 'required this.${e.name},').join('\n')}
    });
    ''';

    return DeclarationCode.fromString(code);
  }

  DeclarationCode _buildFromJson(String className,
      List<_ClassField> fields,) {
    final rawFromJsonFunction = '''
    factory $className.fromJson(Map<String, dynamic> json) {
      return $className(
        ${fields.map(_buildFromJsonLine).join(',\n')}
       );
      }
    ''';

    return DeclarationCode.fromString(rawFromJsonFunction);
  }

  String _buildFromJsonLine(_ClassField field) {
    final name = field.name;
    final type = field.type;
    final generics = field.generics;


    if (field.isBaseType) {
      return "$name: json['$name'] as $type";
    }

    if (field.isCollectionType) {
      final firstGeneric = generics.first;

      if (firstGeneric.isBaseType) {
        return "$name: (json['$name'] as List<dynamic>)"
            ".whereType<$firstGeneric>()"
            ".toList()";
      } else {
        return "$name: (json['$name'] as List<dynamic>)"
            ".whereType<Map<String, dynamic>>()"
            ".map(${generics.first}.fromJson)"
            ".toList()";
      }
    }

    return "$name: $type.fromJson(json['$name'] as Map<String, dynamic>)";
  }

  DeclarationCode _buildToJson(List<_ClassField> fields,) {
    final code = '''
    Map<String, dynamic> toJson() {
      return {
        ${fields.map(_buildToJsonLine)
        .join('\n')}
      };
    }
    ''';

    return DeclarationCode.fromString(code);
  }

  String _buildToJsonLine(_ClassField field) {
    final fieldName = field.name;
    final fieldGenerics = field.generics;

    if (field.isBaseType) {
      return "'$fieldName': $fieldName,";
    }

    if (field.isCollectionType) {
      final firstGeneric = fieldGenerics.first;
      return firstGeneric.isBaseType ? "'$fieldName': $fieldName," :
      "'$fieldName': $fieldName.map((e) => e.toJson()).toList(),";
    }

    return "'$fieldName': $fieldName.toJson(),";
  }

  DeclarationCode _buildCopyWith(String className,
      List<_ClassField> fields,) {
    final code = '''
    $className copyWith({
      ${fields.map((field) => '${field.typeWithGenerics}? ${field.name},').join(
        '\n')}
    }) {
      return $className(
        ${fields.map((field) => '${field.name}: ${field.name} ?? this.${field
        .name},').join('\n')}
      );
    }
    ''';


    return DeclarationCode.fromString(code);
  }


  DeclarationCode _buildEquals(String className,
      List<_ClassField> fields,) {
    final code = '''
    @override
    bool operator ==(Object other) {
      return other is $className &&
      runtimeType == other.runtimeType &&
      ${fields.map((field) => '${field.name} == other.${field.name}').join(
        ' && ')};
    }
    ''';

    return DeclarationCode.fromString(code);
  }

  DeclarationCode _buildHashCode(List<_ClassField> fields) {
    final code = '''
    @override
    int get hashCode {
      return Object.hash(
        runtimeType,
        ${fields.map((field) => '${field.name},').join('\n')}
      );
    }
    ''';
    return DeclarationCode.fromString(code);
  }


  DeclarationCode _buildToString(String className,
      List<_ClassField> fields,) {
    final code = '''
    @override
    String toString() {
      return '$className(${fields.map((field) => '${field.name}: \$${field
        .name}').join(
        ', ')})';
    }
    ''';

    return DeclarationCode.fromString(code);
  }

}

class _ClassField {
  final String name;
  final String type;
  final List<String> generics;

  _ClassField(this.name, this.type, this.generics);

  bool get isBaseType => _baseTypes.contains(type);

  bool get isCollectionType => _collectionTypes.contains(type);

  String get typeWithGenerics =>
      generics.isEmpty ? type : '$type<${generics.join(', ')}>';
}

extension on String {
  bool get isBaseType => _baseTypes.contains(this);

  bool get isCollectionType => _collectionTypes.contains(this);
}
