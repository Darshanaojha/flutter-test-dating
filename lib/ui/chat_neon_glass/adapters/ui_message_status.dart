/// UI-level normalized message status.
///
/// This MUST be derived from existing backend delivery/read state fields.
/// Do not invent new backend statuses.
enum UIMessageStatus {
  pending,
  sent,
  delivered,
  seen,
  failed,
  deleted,
}
