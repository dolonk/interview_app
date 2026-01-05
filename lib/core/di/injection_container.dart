import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/documents/data/datasources/document_local_datasource.dart';
import '../../features/documents/data/repositories/document_repository_impl.dart';
import '../../features/documents/domain/repositories/document_repository.dart';
import '../../features/documents/domain/entities/document_state_entity.dart';
import '../../features/documents/presentation/viewmodels/document_viewmodel.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../../features/editor/domain/entities/editor_state_entity.dart';
import '../../features/editor/data/datasources/editor_local_datasource.dart';
import '../../features/editor/data/repositories/editor_repository_impl.dart';
import '../../features/editor/domain/repositories/editor_repository.dart';
import '../../features/editor/presentation/viewmodels/editor_viewmodel.dart';
import '../../shared/services/isar_service.dart';

// ===== AUTH PROVIDERS =====
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(firebaseAuthProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});

// ===== HOME PROVIDERS (Read-only document list) =====
final homeLocalDataSourceProvider = FutureProvider<HomeLocalDataSource>((ref) async {
  final isar = await IsarService.instance;
  return HomeLocalDataSourceImpl(isar);
});

final homeRepositoryProvider = FutureProvider<HomeRepository>((ref) async {
  final dataSource = await ref.watch(homeLocalDataSourceProvider.future);
  return HomeRepositoryImpl(dataSource);
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repoAsync = ref.watch(homeRepositoryProvider);
  return repoAsync.when(
    data: (repo) => HomeViewModel(repo),
    loading: () => HomeViewModel.loading(),
    error: (e, _) => HomeViewModel.error(e.toString()),
  );
});

// ===== DOCUMENT PROVIDERS (Upload, Delete) =====
final documentLocalDataSourceProvider = FutureProvider<DocumentLocalDataSource>((ref) async {
  final isar = await IsarService.instance;
  return DocumentLocalDataSourceImpl(isar);
});

final documentRepositoryProvider = FutureProvider<DocumentRepository>((ref) async {
  final dataSource = await ref.watch(documentLocalDataSourceProvider.future);
  return DocumentRepositoryImpl(dataSource);
});

final documentViewModelProvider = StateNotifierProvider<DocumentViewModel, DocumentStateEntity>((ref) {
  final repoAsync = ref.watch(documentRepositoryProvider);
  return repoAsync.when(
    data: (repo) => DocumentViewModel(repo),
    loading: () => throw UnimplementedError('Repository still loading'),
    error: (e, _) => throw Exception('Failed to initialize repository: $e'),
  );
});

// ===== EDITOR PROVIDERS (PDF viewing, field placement) =====
final editorLocalDataSourceProvider = Provider<EditorLocalDataSource>((ref) {
  return EditorLocalDataSourceImpl();
});

final editorRepositoryProvider = Provider<EditorRepository>((ref) {
  return EditorRepositoryImpl(ref.read(editorLocalDataSourceProvider));
});

final editorViewModelProvider = StateNotifierProvider.autoDispose<EditorViewModel, EditorStateEntity>((ref) {
  final repo = ref.watch(editorRepositoryProvider);
  return EditorViewModel(repository: repo);
});
