import 'package:axiom/src/encoder/singular_encoder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';

const String _objectType = 'object';
const String _arrayType = 'array';

/// [JsonSchemaParser] is a utility class for extracting main and nested classes from JSON schema contents.
/// for using this utility first you should call `getModels()` method and pass decoded JSON schema to it,
/// then pass the result as `models` parameter to `getClasses()` method.
/// result is a string that contains main class and all related classes of that schema file include:
/// model classes, constructor, properties,  toJson, fromJson, and copyWith methods.
class JsonSchemaParser {
  final List<StringBuffer> _result = <StringBuffer>[];

  static final List<String> _primaryTypes = <String>[
    'int',
    'String',
    'double',
    'bool',
    'num',
  ];

  static final Map<String, String> _typeMap = <String, String>{
    'integer': 'int',
    'string': 'String',
    'number': 'double',
    'boolean': 'bool',
    'num': 'num',
  };

  static String? _getClassName({
    required String name,
    required String? type,
    String? arrayType,
  }) =>
      type == _objectType
          ? ReCase(name).pascalCase
          : type == _arrayType
              ? arrayType != null && _typeMap.containsKey(arrayType)
                  ? _typeMap[arrayType]
                  : SingularEncoder().convert(ReCase(name).pascalCase)
              : _typeMap[type!] ?? 'UNKNOWN_TYPE';

  static String? _getObjectType({
    required String name,
    required String? type,
    String? arrayType,
  }) =>
      type == _arrayType
          ? 'List<${_getClassName(name: name, type: type, arrayType: arrayType)}>'
          : _getClassName(name: name, type: type, arrayType: arrayType);

  static String _generateClass({
    required String className,
    required List<_SchemaModel> models,
  }) {
    final result = StringBuffer()
      ..write(
        '''
          /// ${ReCase(className).sentenceCase} model class
          abstract class ${className}Model {
            /// Initializes
            ${_generateContractor(className: '${className}Model', models: models, isSubclass: false)}
            ${_generateProperties(models: models)}
          }
        
          /// ${ReCase(className).sentenceCase} class
          class $className extends ${className}Model {
            /// Initializes
            ${_generateContractor(className: className, models: models)}
            /// Creates an instance from JSON
            ${_generateFromJson(className: className, models: models)}
            /// Converts an instance to JSON
            ${_generateToJson(models: models)}
            /// Creates a copy of instance with given parameters
            ${_copyWith(className: className, models: models)}
          }
        ''',
      );

    return DartFormatter().format(result.toString());
  }

  static StringBuffer _generateContractor({
    required String className,
    required List<_SchemaModel> models,
    bool isSubclass = true,
  }) {
    final result = StringBuffer()
      ..write(
        '''
          $className({
        ''',
      );

    for (final model in models) {
      result
        ..write('${'required'} ')
        ..write(
          isSubclass
              ? '${model.schemaType}${''} ${model.title},'
              : 'this.${model.title},',
        );
    }

    if (isSubclass) {
      result.write('}) : super(');

      for (final model in models) {
        result.write('${model.title}: ${model.title},');
      }

      result.write(');');
    } else {
      result.write('});');
    }

    return result;
  }

  static StringBuffer _generateProperties({
    required List<_SchemaModel> models,
  }) {
    final result = StringBuffer();

    for (final model in models) {
      result.write(
        '''
          final ${model.schemaType} ${model.title};
        ''',
      );
    }

    return result;
  }

  static StringBuffer _generateFromJson({
    required String className,
    required List<_SchemaModel> models,
  }) {
    final result = StringBuffer(
      'factory $className.fromJson(Map<String, dynamic> json) => $className(',
    );

    for (final model in models) {
      final className = model.className;
      final title = model.title;
      final schemaTitle = model.schemaTitle;
      final schemaType = model.schemaType;
      // print(model.title);

      if (schemaType == _objectType) {
        result.write(
          '''
            $title: json['$schemaTitle'] == null
              ? null
              : $className.fromJson(json['$schemaTitle']),
          ''',
        );
      } else if (schemaType == _arrayType) {
        result.write(
          '''
            $title: json['$schemaTitle'] == null
              ? null
              : json['$schemaTitle'].map<$className>((dynamic item) => 
                  ${_primaryTypes.contains(className) ? 'item' : '$className.fromJson(item)'}).toList(),
          ''',
        );
      } else {
        result.write('''$title: json['$schemaTitle'],''');
      }
    }

    result.write(');');

    return result;
  }

  static StringBuffer _generateToJson({
    required List<_SchemaModel> models,
  }) {
    final result = StringBuffer()
      ..write(
        '''
          Map<String, dynamic> toJson() {
            final Map<String, dynamic> result = <String, dynamic>{};
        ''',
      );

    for (final model in models) {
      final title = model.title;
      final schemaTitle = model.schemaTitle;
      final schemaType = model.schemaType;

      if (schemaType == _objectType) {
        result.write(
          '''
            if ($title != null) {
              result['$schemaTitle'] = $title.toJson();
            }
          ''',
        );
      } else if (schemaType == _arrayType) {
        result.write(
          '''
            if ($title != null) {
              result['$schemaTitle'] = $title.map((item) => item.toJson()).toList();
            }
          ''',
        );
      } else {
        result.write('''result['$schemaTitle'] = $title;''');
      }
    }

    result.write('\n\nreturn result; }');

    return result;
  }

  static StringBuffer _copyWith({
    required String className,
    required List<_SchemaModel> models,
  }) {
    final result = StringBuffer()
      ..write(
        '''
          $className copyWith({
        ''',
      );

    for (final model in models) {
      result.write('${model.schemaType}? ${model.title},');
    }

    result.write('}) => $className(');

    for (final model in models) {
      result.write('${model.title}: ${model.title} ?? this.${model.title},');
    }

    result.write(');');

    return result;
  }

  /// Pass decoded JSON schema to this method for getting list of objects
  List<_SchemaModel> getModels({
    required Map<String, dynamic>? schema,
  }) {
    final parentModel = <_SchemaModel>[];

    if (schema != null) {
      final schemaProperties = schema;

      for (final entry in schemaProperties.entries) {
        final name = entry.key;
        final String? type;

        if (_isDate(entry.value)) {
          type = '$DateTime';
        } else {
          type = entry.value.runtimeType.toString();
        }

        final childModel = _SchemaModel()
          ..className = _getClassName(
            name: name,
            type: type,
          )
          ..title = ReCase(name).camelCase
          ..schemaType = _getObjectType(
            name: name,
            type: type,
          )
          // ..isRequired = _isRequired(entry)
          ..schemaTitle = name
          ..schemaType = type
          ..children = <_SchemaModel>[];

        if (type == _objectType) {
          childModel.children.addAll(
            getModels(schema: entry.value as Map<String, dynamic>?),
          );
        } else if (type == _arrayType) {
          childModel.children.addAll(
            getModels(
              schema: entry.value['items'] as Map<String, dynamic>?,
            ),
          );
        }

        parentModel.add(childModel);
      }
    }

    return parentModel;
  }

  bool _isDate(dynamic str) {
    try {
      DateTime.parse(str as String);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generating main and nested classes from schema models that comes from `getModels()` method.
  StringBuffer getClasses({
    required List<_SchemaModel> models,
    String? className = 'MainClass',
    bool clearResult = true,
  }) {
    if (clearResult) {
      _result.clear();
    }

    if (models.isNotEmpty) {
      _result.add(
        StringBuffer(
          _generateClass(
            className: className!,
            models: models,
          ),
        ),
      );
    }

    for (final model in models) {
      getClasses(
        models: model.children,
        className: model.className,
        clearResult: false,
      );
    }

    return _result[0];
  }
}

/// Model to store schema information
class _SchemaModel {
  /// Class name
  String? className;

  /// Field title
  String? title;

  /// Is required field
  late bool isRequired;

  /// Schema object field title
  String? schemaTitle;

  /// Schema object field type
  String? schemaType;

  /// List of nested classes
  late List<_SchemaModel> children;
}
