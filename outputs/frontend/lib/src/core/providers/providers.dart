import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../models/models.dart';
import '../repositories/mock_repositories.dart';
import '../network/api_client.dart';
import '../repositories/auth_repository.dart';
import '../repositories/draft_repository.dart';
import '../../config/router.dart';

// 1. Repository Providers
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DraftRepository(apiClient);
});

final journalRepositoryProvider = Provider<MockJournalRepository>((ref) {
  return MockJournalRepository();
});

final analyticsRepositoryProvider = Provider<MockAnalyticsRepository>((ref) {
  return MockAnalyticsRepository();
});

final exportRepositoryProvider = Provider<MockExportRepository>((ref) {
  return MockExportRepository();
});

// 2. Auth State Provider
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
    ApiClient.onUnauthorizedGlobal = () {
      clearSessionOnExpiry();
      goRouter.go('/login');
    };
  }

  void clearSessionOnExpiry() {
    state = const AsyncValue.data(null);
  }

  Future<void> _init() async {
    try {
      final user = await _repo.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<User> register(String fullName, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.register(fullName, email, password);
      state = const AsyncValue.data(null);
      return user;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repo.forgotPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repo.logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearError() {
    state = AsyncValue.data(state.value);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

// 3. Categories & Tags Providers (Loaded from repository)
final categoriesProvider = Provider<List<Category>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return List.from(repo.categories);
});

final tagsProvider = Provider<List<Tag>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return List.from(repo.tags);
});

// 4. Journals State Notifier
class JournalsNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final MockJournalRepository _repo;
  JournalsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _repo.getEntries();
      state = AsyncValue.data(entries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addEntry({
    required String title,
    required String content,
    required DateTime entryDate,
    String? categoryId,
    required List<String> tagIds,
    required bool isPrivate,
  }) async {
    final entry = JournalEntry(
      journalId: '',
      userId: 'user-1',
      categoryId: categoryId,
      title: title,
      content: content,
      entryDate: entryDate,
      tagIds: tagIds,
      wordCount: content.trim().split(RegExp(r'\s+')).length,
      isPrivate: isPrivate,
      versionNumber: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _repo.createEntry(entry);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateEntry(JournalEntry entry) async {
    try {
      await _repo.updateEntry(entry);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteEntry(String journalId) async {
    try {
      await _repo.deleteEntry(journalId);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final journalsProvider = StateNotifierProvider<JournalsNotifier, AsyncValue<List<JournalEntry>>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return JournalsNotifier(repo);
});

// 5. Search and Filters State
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);
final selectedTagFilterProvider = StateProvider<String?>((ref) => null);
final selectedDateRangeFilterProvider = StateProvider<DateTimeRange?>((ref) => null);

// 6. Filtered Entries Provider
final filteredEntriesProvider = Provider<AsyncValue<List<JournalEntry>>>((ref) {
  final journalsState = ref.watch(journalsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final catId = ref.watch(selectedCategoryFilterProvider);
  final tagId = ref.watch(selectedTagFilterProvider);
  final dateRange = ref.watch(selectedDateRangeFilterProvider);

  return journalsState.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (entries) {
      final filtered = entries.where((entry) {
        // Filter by query
        if (query.isNotEmpty) {
          final matchesTitle = entry.title.toLowerCase().contains(query);
          final matchesContent = entry.content.toLowerCase().contains(query);
          if (!matchesTitle && !matchesContent) return false;
        }
        // Filter by category
        if (catId != null && entry.categoryId != catId) return false;
        // Filter by tag
        if (tagId != null && !entry.tagIds.contains(tagId)) return false;
        // Filter by date range
        if (dateRange != null) {
          final start = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
          final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day, 23, 59, 59);
          if (entry.entryDate.isBefore(start) || entry.entryDate.isAfter(end)) return false;
        }
        return true;
      }).toList();

      // Sort by entry date descending
      filtered.sort((a, b) => b.entryDate.compareTo(a.entryDate));
      return AsyncValue.data(filtered);
    },
  );
});

// 7. Analytics Provider
final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final journalsState = ref.watch(journalsProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  
  return journalsState.when(
    loading: () => Completer<AnalyticsData>().future,
    error: (err, stack) => Future.error(err, stack),
    data: (entries) => repo.getAnalytics(entries),
  );
});

// 8. Exports Provider
class ExportsNotifier extends StateNotifier<List<ExportJob>> {
  final MockExportRepository _repo;
  Timer? _pollingTimer;

  ExportsNotifier(this._repo) : super([]) {
    _refreshJobs();
    // Start interval refresh to check progress of running jobs
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) => _refreshJobs());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshJobs() async {
    try {
      final jobs = await _repo.getExportJobs();
      state = jobs;
    } catch (_) {}
  }

  Future<void> requestExport(String format) async {
    try {
      await _repo.requestExport(format);
      await _refreshJobs();
    } catch (_) {}
  }
}

final exportsProvider = StateNotifierProvider<ExportsNotifier, List<ExportJob>>((ref) {
  final repo = ref.watch(exportRepositoryProvider);
  return ExportsNotifier(repo);
});

// 9. Theme Mode Provider
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
