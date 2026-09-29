import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'providers.dart';

/// Hanya digunakan saat detail dibuka tanpa data dari list (deep link).
final postDetailProvider = FutureProvider.autoDispose.family<Post, int>(
  (ref, id) => ref.watch(postRepositoryProvider).fetchPost(id),
  retry: (count, error) => null,
);
