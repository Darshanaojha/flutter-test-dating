/// Wrapper around the existing backend message model.
///
/// This avoids changing backend schemas and keeps UI mapping isolated.
///
/// IMPORTANT: Do not add fields that imply backend schema changes.
class RawBackendMessage {
  /// The underlying backend message object (existing model instance).
  final Object raw;

  const RawBackendMessage(this.raw);
}
