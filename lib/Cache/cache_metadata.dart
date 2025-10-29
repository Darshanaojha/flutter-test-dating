class CacheMetadata {
  final String key;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final int ttl;
  final int version;
  final int accessCount;
  final int size;

  CacheMetadata({
    required this.key,
    required this.createdAt,
    required this.lastAccessed,
    required this.ttl,
    required this.version,
    this.accessCount = 0,
    this.size = 0,
  });

  // Check if cache entry is expired
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch > 
           (createdAt.millisecondsSinceEpoch + ttl);
  }

  // Check if cache entry is stale (close to expiration)
  bool get isStale {
    final timeLeft = ttl - (DateTime.now().millisecondsSinceEpoch - createdAt.millisecondsSinceEpoch);
    return timeLeft < (ttl * 0.2).toInt(); // 20% of TTL remaining
  }

  // Update last accessed time and increment counter
  CacheMetadata updateAccess() {
    return CacheMetadata(
      key: key,
      createdAt: createdAt,
      lastAccessed: DateTime.now(),
      ttl: ttl,
      version: version,
      accessCount: accessCount + 1,
      size: size,
    );
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastAccessed': lastAccessed.millisecondsSinceEpoch,
      'ttl': ttl,
      'version': version,
      'accessCount': accessCount,
      'size': size,
    };
  }

  // Create from Map
  factory CacheMetadata.fromMap(Map<String, dynamic> map) {
    return CacheMetadata(
      key: map['key'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(map['lastAccessed']),
      ttl: map['ttl'],
      version: map['version'],
      accessCount: map['accessCount'] ?? 0,
      size: map['size'] ?? 0,
    );
  }
}
