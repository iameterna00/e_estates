import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchStateNotifier extends StateNotifier<String> {
  SearchStateNotifier() : super('');

  void updateSearchQuery(String newQuery) {
    state = newQuery.toLowerCase();
  }
}

final searchStateProvider =
    StateNotifierProvider<SearchStateNotifier, String>((ref) {
  return SearchStateNotifier();
});
