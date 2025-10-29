import 'dart:async';
import '../Models/Entities/user_entity.dart';
import '../Models/Entities/chat_message_entity.dart';
import '../Cache/cache_config.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  // Offline queue for pending operations
  final List<PendingOperation> _pendingOperations = [];
  bool _isOnline = true;
  Timer? _syncTimer;
  bool _isSyncing = false;

  // Operation types
  static const String _operationSaveUser = 'save_user';
  static const String _operationUpdateUser = 'update_user';
  static const String _operationDeleteUser = 'delete_user';
  static const String _operationSaveMessage = 'save_message';
  static const String _operationMarkRead = 'mark_read';
  static const String _operationMarkDelivered = 'mark_delivered';
  static const String _operationDeleteMessage = 'delete_message';

  // Initialize sync manager
  void initialize() {
    _startBackgroundSync();
  }

  // Set online/offline status
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    if (isOnline && _pendingOperations.isNotEmpty) {
      _triggerSync();
    }
  }

  // Add operation to pending queue
  Future<void> addPendingOperation(PendingOperation operation) async {
    _pendingOperations.add(operation);
    
    if (_isOnline) {
      _triggerSync();
    }
  }

  // Queue user save operation
  Future<void> queueSaveUser(UserEntity user) async {
    await addPendingOperation(PendingOperation(
      type: _operationSaveUser,
      data: user.toMap(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      retryCount: 0,
    ));
  }

  // Queue user update operation
  Future<void> queueUpdateUser(UserEntity user) async {
    await addPendingOperation(PendingOperation(
      type: _operationUpdateUser,
      data: user.toMap(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      retryCount: 0,
    ));
  }

  // Queue user delete operation
  Future<void> queueDeleteUser(String userId) async {
    await addPendingOperation(PendingOperation(
      type: _operationDeleteUser,
      data: {'userId': userId},
      timestamp: DateTime.now().millisecondsSinceEpoch,
      retryCount: 0,
    ));
  }

  // Queue message save operation
  Future<void> queueSaveMessage(ChatMessageEntity message) async {
    await addPendingOperation(PendingOperation(
      type: _operationSaveMessage,
      data: message.toMap(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      retryCount: 0,
    ));
  }

  // Queue mark as read operation
  Future<void> queueMarkAsRead(String messageId) async {
    await addPendingOperation(PendingOperation(
      type: _operationMarkRead,
      data: {'messageId': messageId},
      timestamp: DateTime.now().millisecondsSinceEpoch,
      retryCount: 0,
    ));
  }

  // Queue mark as delivered operation
  Future<void> queueMarkAsDelivered(String messageId) async {
    await addPendingOperation(PendingOperation(
      type: _operationMarkDelivered,
      data: {'messageId': messageId},
      timestamp: DateTime.now().millisecondsSinceEpoch,
      retryCount: 0,
    ));
  }

  // Queue message delete operation
  Future<void> queueDeleteMessage(String messageId) async {
    await addPendingOperation(PendingOperation(
      type: _operationDeleteMessage,
      data: {'messageId': messageId},
      timestamp: DateTime.now().millisecondsSinceEpoch,
      retryCount: 0,
    ));
  }

  // Start background sync timer
  void _startBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      Duration(milliseconds: CacheConfig.backgroundSyncInterval),
      (_) => _triggerSync(),
    );
  }

  // Trigger sync process
  Future<void> _triggerSync() async {
    if (!_isOnline || _isSyncing || _pendingOperations.isEmpty) {
      return;
    }

    _isSyncing = true;
    
    try {
      await _processPendingOperations();
    } catch (e) {
      if (CacheConfig.enableDebugLogging) {
        print('Sync error: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Process all pending operations
  Future<void> _processPendingOperations() async {
    final operations = List<PendingOperation>.from(_pendingOperations);
    
    for (final operation in operations) {
      try {
        await _executeOperation(operation);
        _pendingOperations.remove(operation);
      } catch (e) {
        operation.retryCount++;
        
        if (operation.retryCount >= 3) {
          _pendingOperations.remove(operation);
          if (CacheConfig.enableDebugLogging) {
            print('Operation failed after 3 retries: ${operation.type}');
          }
        } else {
          // Retry with exponential backoff
          await Future.delayed(Duration(
            milliseconds: CacheConfig.retrySyncInterval * operation.retryCount,
          ));
        }
      }
    }
  }

  // Execute individual operation
  Future<void> _executeOperation(PendingOperation operation) async {
    switch (operation.type) {
      case _operationSaveUser:
        final user = UserEntity.fromMap(operation.data);
        // Here you would integrate with your actual API/service
        break;
        
      case _operationUpdateUser:
        final user = UserEntity.fromMap(operation.data);
        // Here you would integrate with your actual API/service
        break;
        
      case _operationDeleteUser:
        final userId = operation.data['userId'] as String;
        // Here you would integrate with your actual API/service
        break;
        
      case _operationSaveMessage:
        final message = ChatMessageEntity.fromMap(operation.data);
        // Here you would integrate with your actual API/service
        break;
        
      case _operationMarkRead:
        final messageId = operation.data['messageId'] as String;
        // Here you would integrate with your actual API/service
        break;
        
      case _operationMarkDelivered:
        final messageId = operation.data['messageId'] as String;
        // Here you would integrate with your actual API/service
        break;
        
      case _operationDeleteMessage:
        final messageId = operation.data['messageId'] as String;
        // Here you would integrate with your actual API/service
        break;
    }
  }

  // Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;

  // Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'pendingOperations': _pendingOperations.length,
      'lastSyncTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Clear all pending operations
  void clearPendingOperations() {
    _pendingOperations.clear();
  }

  // Dispose sync manager
  void dispose() {
    _syncTimer?.cancel();
    _pendingOperations.clear();
  }
}

class PendingOperation {
  final String type;
  final Map<String, dynamic> data;
  final int timestamp;
  int retryCount;

  PendingOperation({
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp,
      'retryCount': retryCount,
    };
  }

  factory PendingOperation.fromMap(Map<String, dynamic> map) {
    return PendingOperation(
      type: map['type'],
      data: Map<String, dynamic>.from(map['data']),
      timestamp: map['timestamp'],
      retryCount: map['retryCount'] ?? 0,
    );
  }
}
