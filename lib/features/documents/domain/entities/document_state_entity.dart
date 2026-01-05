import 'package:equatable/equatable.dart';
import '../../../../shared/entities/document_entity.dart';
import '../../../../core/errors/failures.dart';

class DocumentStateEntity extends Equatable {
  final List<DocumentEntity> documents;
  final bool isLoading;
  final bool isInitializing;
  final Failure? failure;
  final String? successMessage;
  final DocumentEntity? lastUploadedDocument;

  const DocumentStateEntity({
    this.documents = const [],
    this.isLoading = false,
    this.isInitializing = false,
    this.failure,
    this.successMessage,
    this.lastUploadedDocument,
  });

  DocumentStateEntity copyWith({
    List<DocumentEntity>? documents,
    bool? isLoading,
    bool? isInitializing,
    Failure? failure,
    String? successMessage,
    DocumentEntity? lastUploadedDocument,
    bool clearLastUploaded = false,
  }) {
    return DocumentStateEntity(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      failure: failure,
      successMessage: successMessage,
      lastUploadedDocument: clearLastUploaded ? null : (lastUploadedDocument ?? this.lastUploadedDocument),
    );
  }

  factory DocumentStateEntity.initial() => const DocumentStateEntity();
  factory DocumentStateEntity.loading() => const DocumentStateEntity(isLoading: true);
  factory DocumentStateEntity.initializing() => const DocumentStateEntity(isInitializing: true);

  @override
  List<Object?> get props => [documents, isLoading, isInitializing, failure, successMessage, lastUploadedDocument];
}
