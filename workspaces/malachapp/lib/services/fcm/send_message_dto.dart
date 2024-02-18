class SendMessageDto {
  final String? to;
  final NotificationBody notification;

  SendMessageDto({
    this.to,
    required this.notification,
  });
}

class NotificationBody {
  final String title;
  final String body;

  NotificationBody({
    required this.title,
    required this.body,
  });
}
