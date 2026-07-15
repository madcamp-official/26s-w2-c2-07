class MemoryCache {
  MemoryCache({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _CacheEntry<Object?>> _items = {};

  T? read<T>(String key) {
    final entry = _items[key];
    if (entry == null) return null;

    final isExpired = DateTime.now().difference(entry.savedAt) > ttl;
    if (isExpired) {
      _items.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  void write<T>(String key, T value) {
    _items[key] = _CacheEntry<Object?>(value, DateTime.now());
  }

  void remove(String key) {
    _items.remove(key);
  }

  void removeWhere(bool Function(String key) test) {
    _items.removeWhere((key, _) => test(key));
  }

  void clear() {
    _items.clear();
  }
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.savedAt);

  final T value;
  final DateTime savedAt;
}

final repositoryCache = MemoryCache();
