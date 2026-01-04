import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/entities/field_entity.dart';

abstract class EditorRepository {
  /// Save field configuration as JSON
  Future<Either<Failure, String>> saveFieldConfig({required int documentId, required List<FieldEntity> fields});

  /// Load field configuration from JSON
  Future<Either<Failure, List<FieldEntity>>> loadFieldConfig(int documentId);

  /// Delete field configuration
  Future<Either<Failure, bool>> deleteFieldConfig(int documentId);
}
