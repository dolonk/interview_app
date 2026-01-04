import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/entities/document_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/home_repository.dart';

/// State for home feature
class HomeState {
  final List<DocumentEntity> documents;
  final bool isLoading;
  final bool isInitializing;
  final Failure? failure;

  const HomeState({this.documents = const [], this.isLoading = false, this.isInitializing = false, this.failure});

  HomeState copyWith({
    List<DocumentEntity>? documents,
    bool? isLoading,
    bool? isInitializing,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return HomeState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  factory HomeState.initial() => const HomeState();
  factory HomeState.initializing() => const HomeState(isInitializing: true);
}

/// ViewModel for home feature
class HomeViewModel extends StateNotifier<HomeState> {
  final HomeRepository? _repository;

  HomeViewModel(this._repository) : super(HomeState.initial());

  // Factory for loading state
  factory HomeViewModel.loading() {
    return HomeViewModel._internal(null, isInitializing: true);
  }

  // Factory for error state
  factory HomeViewModel.error(String message) {
    return HomeViewModel._internal(null, errorMessage: message);
  }

  HomeViewModel._internal(this._repository, {bool isInitializing = false, String? errorMessage})
    : super(
        isInitializing
            ? HomeState.initializing()
            : errorMessage != null
            ? HomeState(failure: CacheFailure(errorMessage))
            : HomeState.initial(),
      );

  /// Load documents for a user
  Future<void> loadDocuments(String userId) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, isInitializing: false, clearFailure: true);

    final result = await _repository.getDocuments(userId);

    state = result.fold(
      (failure) => state.copyWith(isLoading: false, failure: failure),
      (documents) => state.copyWith(isLoading: false, documents: documents),
    );
  }

  /// Refresh documents
  Future<void> refresh(String userId) async {
    await loadDocuments(userId);
  }

  /// Clear failure
  void clearFailure() {
    state = state.copyWith(clearFailure: true);
  }
}
