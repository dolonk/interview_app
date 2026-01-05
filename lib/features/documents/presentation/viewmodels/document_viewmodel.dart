import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/entities/document_state_entity.dart';

class DocumentViewModel extends StateNotifier<DocumentStateEntity> {
  final DocumentRepository _repository;
  DocumentViewModel(this._repository) : super(DocumentStateEntity.initial());

  /// Load all documents for a user
  Future<void> loadDocuments(String userId) async {
    state = state.copyWith(isLoading: true, isInitializing: false);

    final result = await _repository.getDocuments(userId);

    state = result.fold(
      (failure) => state.copyWith(isLoading: false, failure: failure),
      (documents) => state.copyWith(isLoading: false, documents: documents),
    );
  }

  /// Pick and upload a document
  Future<void> pickAndUploadDocument(String userId) async {
    try {
      // Open file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) {
        state = state.copyWith(failure: const FileFailure('Could not access the file'));
        return;
      }

      state = state.copyWith(isLoading: true);
      final fileType = file.extension?.toLowerCase() ?? 'pdf';

      // Save document
      final saveResult = await _repository.saveDocument(
        filePath: file.path!,
        fileName: file.name,
        userId: userId,
        fileType: fileType,
      );

      await saveResult.fold(
        (failure) async {
          state = state.copyWith(isLoading: false, failure: failure);
        },
        (document) async {
          // Reload documents and set lastUploadedDocument for navigation
          await loadDocuments(userId);
          state = state.copyWith(successMessage: 'Document uploaded successfully', lastUploadedDocument: document);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, failure: FileFailure('Failed to pick file: $e'));
    }
  }

  /// Clear last uploaded document (after navigation)
  void clearLastUploadedDocument() {
    state = state.copyWith(clearLastUploaded: true);
  }

  /// Delete a document
  Future<void> deleteDocument(int id, String userId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.deleteDocument(id);

    await result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (success) async {
        await loadDocuments(userId);
        state = state.copyWith(successMessage: 'Document deleted');
      },
    );
  }

  /// Clear error/success messages
  void clearMessages() {
    state = state.copyWith(failure: null, successMessage: null);
  }
}
