import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/entities/field_entity.dart';
import '../../domain/repositories/editor_repository.dart';
import '../datasources/editor_local_datasource.dart';

class EditorRepositoryImpl implements EditorRepository {
  final EditorLocalDataSource _localDataSource;

  EditorRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, String>> saveFieldConfig({required int documentId, required List<FieldEntity> fields}) async {
    try {
      final configPath = await _localDataSource.saveFieldConfig(documentId: documentId, fields: fields);
      return Right(configPath);
    } on FileException catch (e) {
      return Left(FileFailure(e.message));
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FieldEntity>>> loadFieldConfig(int documentId) async {
    try {
      final fields = await _localDataSource.loadFieldConfig(documentId);
      return Right(fields);
    } on FileException catch (e) {
      return Left(FileFailure(e.message));
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFieldConfig(int documentId) async {
    try {
      final result = await _localDataSource.deleteFieldConfig(documentId);
      return Right(result);
    } on FileException catch (e) {
      return Left(FileFailure(e.message));
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }
}
