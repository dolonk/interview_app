import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../shared/entities/field_entity.dart';
import '../../../../shared/entities/document_entity.dart';
import '../../../../core/errors/failures.dart';

enum EditorMode { edit, sign }

class EditorStateEntity extends Equatable {
  final DocumentEntity? document;
  final List<FieldEntity> fields;
  final FieldEntity? selectedField;
  final int currentPage;
  final int totalPages;
  final Map<int, Uint8List> pageImages;
  final double pdfPageWidth;
  final double pdfPageHeight;
  final EditorMode mode;
  final bool isLoading;
  final bool isRenderingPage;
  final bool isSaving;
  final bool isPublished;
  final Failure? failure;
  final String? successMessage;

  const EditorStateEntity({
    this.document,
    this.fields = const [],
    this.selectedField,
    this.currentPage = 1,
    this.totalPages = 1,
    this.pageImages = const {},
    this.pdfPageWidth = 0,
    this.pdfPageHeight = 0,
    this.mode = EditorMode.edit,
    this.isLoading = false,
    this.isRenderingPage = false,
    this.isSaving = false,
    this.isPublished = false,
    this.failure,
    this.successMessage,
  });

  /// Check if editing is allowed
  bool get canEdit => !isPublished && mode == EditorMode.edit;

  /// Get current page image
  Uint8List? get currentPageImage => pageImages[currentPage];

  /// Copy with new values
  EditorStateEntity copyWith({
    DocumentEntity? document,
    List<FieldEntity>? fields,
    FieldEntity? selectedField,
    bool clearSelection = false,
    int? currentPage,
    int? totalPages,
    Map<int, Uint8List>? pageImages,
    double? pdfPageWidth,
    double? pdfPageHeight,
    EditorMode? mode,
    bool? isLoading,
    bool? isRenderingPage,
    bool? isSaving,
    bool? isPublished,
    Failure? failure,
    String? successMessage,
  }) {
    return EditorStateEntity(
      document: document ?? this.document,
      fields: fields ?? this.fields,
      selectedField: clearSelection ? null : (selectedField ?? this.selectedField),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      pageImages: pageImages ?? this.pageImages,
      pdfPageWidth: pdfPageWidth ?? this.pdfPageWidth,
      pdfPageHeight: pdfPageHeight ?? this.pdfPageHeight,
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      isRenderingPage: isRenderingPage ?? this.isRenderingPage,
      isSaving: isSaving ?? this.isSaving,
      isPublished: isPublished ?? this.isPublished,
      failure: failure,
      successMessage: successMessage,
    );
  }

  /// Factory constructors
  factory EditorStateEntity.initial() => const EditorStateEntity();
  factory EditorStateEntity.loading() => const EditorStateEntity(isLoading: true);

  @override
  List<Object?> get props => [
    document,
    fields,
    selectedField,
    currentPage,
    totalPages,
    pageImages,
    pdfPageWidth,
    pdfPageHeight,
    mode,
    isLoading,
    isRenderingPage,
    isSaving,
    isPublished,
    failure,
    successMessage,
  ];
}
