import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/repositories/message_repo.dart';
import 'package:flutter_app/services/chat_bot_service.dart' ; 

class AllMessagesViewModel with ChangeNotifier {

  final ChatBot chatService; 
  final MessageRepository _messageRepository;
  StreamSubscription<List<Message>>? _messagesSubscription;

  List<Message> _messages = [];
  List<Message> get messages => _messages;
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  AllMessagesViewModel({required this.chatService , MessageRepository? messageRepository})
      : _messageRepository = messageRepository ?? MessageRepository() {
    _messagesSubscription = _messageRepository.streamViewMessages().listen(
      (messages) {
        _isInitializing = false;
        _messages = messages;
        notifyListeners();
      },
    );

    // _messages.add(Message(text: "Hi , how can I help you", userName: "BOT",timeStamp: DateTime.now()));
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<String> addMessage(Message newMessage) async {
    final response = await chatService.doResponse(newMessage);
    return _handleResponse(newMessage, response);
  }

  String _handleResponse(Message message, String? response) {
    if (response == null) return "Error";

    final String imageDescription = response.split('//').length == 1 ? "" : response.split('//')[1];
    final String userResponse = response.split('//')[0];
    debugPrint('Handling response: $userResponse // $imageDescription');

    var m = Message(
      userName: message.userName,
      text: message.text,
      base64ImageUrl: message.base64ImageUrl,
      timeStamp: DateTime.now(),
      imageDescription: imageDescription,
    );

    _messageRepository.addMessage(m);

    m = Message(
      userName: "BOT",
      text: userResponse,
      base64ImageUrl: null,
      timeStamp: DateTime.now(),
      imageDescription: null,
    );

     _messageRepository.addMessage(m);

    return userResponse;
  }

  List<Map<String, dynamic>> get contentMessages {
    return messages.map((message) => message.contentMessage).toList();
  }

  // Future<void> deleteMessage(String messageId) async {
  //   await _messageRepository.deleteMessage(messageId);
  // }
}
