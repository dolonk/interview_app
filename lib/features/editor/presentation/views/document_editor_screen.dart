import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../shared/entities/document_entity.dart';
import '../../../../shared/entities/field_entity.dart';
import '../../../../core/di/injection_container.dart';
import '../viewmodels/editor_viewmodel.dart';
import '../widgets/draggable_field.dart';
import '../widgets/field_toolbar.dart';
import '../widgets/page_navigation.dart';
import '../widgets/field_input_dialog.dart';
import '../../../../core/theme/app_colors.dart';

class DocumentEditorScreen extends ConsumerStatefulWidget {
  final DocumentEntity document;

  const DocumentEditorScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends ConsumerState<DocumentEditorScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController? _pdfController;
  FieldType? _selectedFieldType;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorViewModelProvider);
    final isEditMode = editorState.canEdit;

    ref.listen(editorViewModelProvider, (previous, next) {
      if (next.failure != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.failure!.message), backgroundColor: AppColors.error));
        ref.read(editorViewModelProvider.notifier).clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.successMessage!), backgroundColor: AppColors.success));
        ref.read(editorViewModelProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(editorState),
      body: Column(
        children: [
          if (editorState.isPublished) _buildPublishedBanner(),
          Expanded(child: _buildPdfViewerWithOverlay(editorState, isEditMode)),
          if (editorState.totalPages > 1)
            PageNavigation(
              currentPage: editorState.currentPage,
              totalPages: editorState.totalPages,
              onFirstPage: () => ref.read(editorViewModelProvider.notifier).firstPage(),
              onPreviousPage: () => ref.read(editorViewModelProvider.notifier).previousPage(),
              onNextPage: () => ref.read(editorViewModelProvider.notifier).nextPage(),
              onLastPage: () => ref.read(editorViewModelProvider.notifier).lastPage(),
            ),
          if (isEditMode) FieldToolbar(onFieldSelected: _onFieldTypeSelected, isEnabled: true),
        ],
      ),
    );
  }

  Widget _buildPublishedBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      color: AppColors.success.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            'Published - Tap fields to fill and sign',
            style: TextStyle(color: AppColors.success, fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(EditorState state) {
    final isEditMode = state.canEdit;
    final isPublished = state.isPublished;

    return AppBar(
      title: Text(
        widget.document.name,
        style: TextStyle(fontSize: 16.sp),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'export':
                _exportFieldsJson();
                break;
              case 'import':
                _importFieldsJson();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              enabled: state.fields.isNotEmpty,
              child: Row(
                children: [
                  const Icon(Icons.upload_file, size: 20),
                  SizedBox(width: 8.w),
                  const Text('Export Fields (JSON)'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'import',
              enabled: !isPublished,
              child: Row(
                children: [
                  const Icon(Icons.download, size: 20),
                  SizedBox(width: 8.w),
                  const Text('Import Fields (JSON)'),
                ],
              ),
            ),
          ],
        ),
        if (isEditMode && !isPublished)
          state.isSaving
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const Center(
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => ref.read(editorViewModelProvider.notifier).saveFields(),
                  tooltip: 'Save',
                ),
        if (!isPublished)
          TextButton.icon(
            onPressed: _toggleMode,
            icon: Icon(
              isEditMode ? Icons.visibility : Icons.edit,
              color: isEditMode ? AppColors.info : AppColors.primary,
            ),
            label: Text(
              isEditMode ? 'Preview' : 'Edit',
              style: TextStyle(color: isEditMode ? AppColors.info : AppColors.primary),
            ),
          ),
        if (isEditMode && !isPublished)
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ElevatedButton.icon(
              onPressed: _onPublish,
              icon: Icon(Icons.publish, size: 18.sp),
              label: const Text('Publish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
              ),
            ),
          ),
      ],
    );
  }

  /// Export fields to JSON file
  Future<void> _exportFieldsJson() async {
    final viewModel = ref.read(editorViewModelProvider.notifier);
    // Use ViewModel to generate JSON
    final jsonString = viewModel.exportFieldsToJson();

    try {
      // Save to Downloads folder using external storage on Android
      Directory? exportDir;
      if (Platform.isAndroid) {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final pathParts = extDir.path.split('/');
          final downloadPath = '/${pathParts[1]}/${pathParts[2]}/${pathParts[3]}/Download';
          exportDir = Directory(downloadPath);
        }
      }

      exportDir ??= await getApplicationDocumentsDirectory();

      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final fileName = '${widget.document.name.replaceAll(' ', '_')}_fields.json';
      final file = File('${exportDir.path}/$fileName');
      await file.writeAsString(jsonString);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (ctx) => Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Exported Successfully!',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Saved to:',
                style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8.r)),
                child: Text(
                  file.path,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'monospace'),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await SharePlus.instance.share(
                          ShareParams(files: [XFile(file.path)], subject: 'Field Config - ${widget.document.name}'),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  /// Import fields from JSON file
  Future<void> _importFieldsJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Fields?'),
          content: const Text('This will replace current fields with imported fields.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Import')),
          ],
        ),
      );

      if (confirm == true) {
        // Use ViewModel to parse and update state
        try {
          ref.read(editorViewModelProvider.notifier).importFieldsFromJson(jsonString);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Invalid Import: $e'), backgroundColor: AppColors.error));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Widget _buildPdfViewerWithOverlay(EditorState state, bool isEditMode) {
    final file = File(widget.document.localFilePath);

    if (!file.existsSync()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Document not found',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: isEditMode ? (details) => _onPdfTap(details, constraints) : null,
          child: Stack(
            children: [
              SfPdfViewer.file(
                file,
                key: _pdfViewerKey,
                controller: _pdfController,
                canShowScrollHead: false,
                canShowScrollStatus: false,
                enableDoubleTapZooming: true,
                onDocumentLoaded: (details) {
                  ref.read(editorViewModelProvider.notifier).setTotalPages(details.document.pages.count);
                  ref
                      .read(editorViewModelProvider.notifier)
                      .initDocument(widget.document, details.document.pages.count);
                },
                onPageChanged: (details) {
                  ref.read(editorViewModelProvider.notifier).goToPage(details.newPageNumber);
                },
              ),
              _buildFieldOverlay(state, isEditMode, constraints),
              if (_selectedFieldType != null && isEditMode)
                Positioned(
                  top: 8.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20.r)),
                      child: Text(
                        'Tap to place ${FieldEntity.getDisplayName(_selectedFieldType!)}',
                        style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldOverlay(EditorState state, bool isEditMode, BoxConstraints constraints) {
    final currentPageFields = state.fields.where((f) => f.page == state.currentPage).toList();
    if (currentPageFields.isEmpty) return const SizedBox.shrink();

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: currentPageFields.map((field) {
          return DraggableField(
            key: ValueKey(field.id),
            field: field,
            isSelected: state.selectedField?.id == field.id,
            isDraggable: isEditMode,
            pageWidth: constraints.maxWidth,
            pageHeight: constraints.maxHeight,
            onTap: () {
              if (isEditMode) {
                ref.read(editorViewModelProvider.notifier).selectField(field.id);
              } else {
                _showFieldInputDialog(field);
              }
            },
            onDelete: () => ref.read(editorViewModelProvider.notifier).deleteField(field.id),
            onPositionChanged: (x, y) => ref.read(editorViewModelProvider.notifier).updateFieldPosition(field.id, x, y),
            onSizeChanged: (w, h) => ref.read(editorViewModelProvider.notifier).updateFieldSize(field.id, w, h),
          );
        }).toList(),
      ),
    );
  }

  void _onFieldTypeSelected(FieldType type) {
    setState(() => _selectedFieldType = type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tap on document to place ${FieldEntity.getDisplayName(type)}'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _onPdfTap(TapUpDetails details, BoxConstraints constraints) {
    if (_selectedFieldType == null) {
      ref.read(editorViewModelProvider.notifier).clearSelection();
      return;
    }

    final xPercent = details.localPosition.dx / constraints.maxWidth;
    final yPercent = details.localPosition.dy / constraints.maxHeight;

    ref
        .read(editorViewModelProvider.notifier)
        .addField(_selectedFieldType!, xPercent.clamp(0.0, 0.85), yPercent.clamp(0.0, 0.9));
    setState(() => _selectedFieldType = null);
  }

  void _showFieldInputDialog(FieldEntity field) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => FieldInputDialog(field: field),
    );

    if (result != null) {
      ref.read(editorViewModelProvider.notifier).updateFieldValue(field.id, result);
    }
  }

  void _toggleMode() {
    final editorNotifier = ref.read(editorViewModelProvider.notifier);
    final currentMode = ref.read(editorViewModelProvider).mode;

    if (currentMode == EditorMode.edit) {
      editorNotifier.enterSignMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview mode - Tap fields to test input'), backgroundColor: AppColors.info),
      );
    } else {
      editorNotifier.enterEditMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit mode - Drag fields to reposition'), backgroundColor: AppColors.info),
      );
    }
  }

  void _onPublish() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Document?'),
        content: const Text(
          'Once published, you cannot edit field positions.\n\nThe document will be ready for signing.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Publish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(editorViewModelProvider.notifier).publishDocument();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document published successfully!'), backgroundColor: AppColors.success),
        );
      }
    }
  }
}
