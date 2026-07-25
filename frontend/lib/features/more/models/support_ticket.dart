class SupportTicket {
  final String id;
  final String userId;
  final String? orderId;
  final String ticketNumber;
  final String subject;
  final String category;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const SupportTicket({
    required this.id,
    required this.userId,
    this.orderId,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      orderId: json['order_id'] as String?,
      ticketNumber: json['ticket_number'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'medium',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
    );
  }
}

class SupportMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderRole;
  final String message;
  final List<String> attachments;
  final bool isInternal;
  final DateTime createdAt;

  const SupportMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    this.attachments = const [],
    required this.isInternal,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    List<String> parsedAttachments = [];
    if (json['attachments'] is List) {
      parsedAttachments = (json['attachments'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return SupportMessage(
      id: json['id'] as String? ?? '',
      ticketId: json['ticket_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderRole: json['sender_role'] as String? ?? 'customer',
      message: json['message'] as String? ?? '',
      attachments: parsedAttachments,
      isInternal: json['is_internal'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
