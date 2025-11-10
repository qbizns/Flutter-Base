/// Audit Log Entry
///
/// Tracks all system changes for security and compliance
class AuditLog {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String action;
  final String entity;
  final String entityId;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String ipAddress;

  const AuditLog({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entity,
    required this.entityId,
    this.description,
    this.metadata,
    required this.ipAddress,
  });
}

/// Audit Action Types
enum AuditAction {
  create('Created', 'created'),
  update('Updated', 'updated'),
  delete('Deleted', 'deleted'),
  login('Logged In', 'logged in'),
  logout('Logged Out', 'logged out'),
  export('Exported', 'exported'),
  import('Imported', 'imported'),
  backup('Backed Up', 'backed up'),
  restore('Restored', 'restored');

  final String label;
  final String pastTense;

  const AuditAction(this.label, this.pastTense);
}
