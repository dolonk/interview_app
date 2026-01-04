import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../shared/entities/field_entity.dart';
import '../../../../core/errors/exceptions.dart';

abstract class EditorLocalDataSource {
  /// Save fields to JSON file
  Future<String> saveFieldConfig({required int documentId, required List<FieldEntity> fields});

  /// Load fields from JSON file
  Future<List<FieldEntity>> loadFieldConfig(int documentId);

  /// Delete field config file
  Future<bool> deleteFieldConfig(int documentId);

  /// Check if config exists
  Future<bool> hasFieldConfig(int documentId);
}

class EditorLocalDataSourceImpl implements EditorLocalDataSource {
  /// Get config directory path
  Future<String> get _configDirPath async {
    final appDir = await getApplicationDocumentsDirectory();
    final configDir = Directory('${appDir.path}/field_configs');
    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }
    return configDir.path;
  }

  /// Get config file path for a document
  Future<String> _getConfigPath(int documentId) async {
    final dirPath = await _configDirPath;
    return '$dirPath/doc_${documentId}_fields.json';
  }

  @override
  Future<String> saveFieldConfig({required int documentId, required List<FieldEntity> fields}) async {
    try {
      final configPath = await _getConfigPath(documentId);
      final file = File(configPath);

      final jsonList = fields.map((f) => f.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await file.writeAsString(jsonString);
      return configPath;
    } catch (e) {
      throw FileException('Failed to save field config: $e');
    }
  }

  @override
  Future<List<FieldEntity>> loadFieldConfig(int documentId) async {
    try {
      final configPath = await _getConfigPath(documentId);
      final file = File(configPath);

      if (!await file.exists()) {
        return []; // No config yet, return empty list
      }

      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;

      return jsonList.map((json) => FieldEntity.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FileException('Failed to load field config: $e');
    }
  }

  @override
  Future<bool> deleteFieldConfig(int documentId) async {
    try {
      final configPath = await _getConfigPath(documentId);
      final file = File(configPath);

      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      throw FileException('Failed to delete field config: $e');
    }
  }

  @override
  Future<bool> hasFieldConfig(int documentId) async {
    final configPath = await _getConfigPath(documentId);
    return File(configPath).exists();
  }
}
