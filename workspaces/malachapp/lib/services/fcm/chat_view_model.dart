import 'package:flutter/material.dart';
import 'package:malachapp/services/fcm/send_message_dto.dart';
import 'chat_state.dart';
import 'fcm_api_service.dart';

class ChatViewModel extends ChangeNotifier {
  ChatState _state = ChatState();
  ChatState get state => _state;

  final FcmApiService _apiService = FcmApiService();

  void onRemoteTokenChange(String newToken) {
    _state = _state.copyWith(remoteToken: newToken);
    notifyListeners();
  }

  void onSubmitRemoteToken() {
    _state = _state.copyWith(isEnteringToken: false);
    notifyListeners();
  }

  void onMessageChange(String message) {
    _state = _state.copyWith(messageText: message);
    notifyListeners();
  }

  Future<void> sendMessage(bool isBroadcast) async {
    final messageDto = SendMessageDto(
      to: isBroadcast ? null : _state.remoteToken,
      notification: NotificationBody(
        title: "New message!",
        body: _state.messageText,
      ),
    );

    try {
      if (isBroadcast) {
        await _apiService.broadcast(messageDto);
      } else {
        await _apiService.sendMessage(messageDto);
      }

      _state = _state.copyWith(messageText: "");
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}
