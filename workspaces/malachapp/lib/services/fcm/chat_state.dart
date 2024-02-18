class ChatState {
  final bool isEnteringToken;
  final String remoteToken;
  final String messageText;

  ChatState({
    this.isEnteringToken = true,
    this.remoteToken = "",
    this.messageText = "",
  });

  ChatState copyWith({
    bool? isEnteringToken,
    String? remoteToken,
    String? messageText,
  }) {
    return ChatState(
      isEnteringToken: isEnteringToken ?? this.isEnteringToken,
      remoteToken: remoteToken ?? this.remoteToken,
      messageText: messageText ?? this.messageText,
    );
  }
}
