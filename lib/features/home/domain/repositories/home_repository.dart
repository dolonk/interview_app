import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/entities/document_entity.dart';

abstract class HomeRepository {
  /// Get all documents for a user
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(String userId);

  /// Get document count for a user
  Future<Either<Failure, int>> getDocumentCount(String userId);
}
