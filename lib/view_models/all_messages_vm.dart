// lib/view_models/all_messages_vm.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/services/chat_bot_service_langchain.dart';

class AllMessagesViewModel with ChangeNotifier {
  final ChatBotServiceLangChain chatService;
  AllMessagesViewModel({required this.chatService}) {
    _messages.add(Message(text: "Hi, how can I help you?", role: "BOT"));
  }

  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  Future<void> addMessage(Message newMessage) async {
    if (_messages.isNotEmpty) {
      // _message empty then welcome user
      _messages.add(Message(text: newMessage.text, role: "user"));
      notifyListeners();
    }

    String response;
    if (newMessage.base64ImageUrl != null) {
      response = await chatService.processImage(newMessage.base64ImageUrl!);
    } else {
      response = await chatService.processMessage(newMessage.text);
    }

    _messages.add(Message(text: response, role: "BOT"));
    notifyListeners();
  }
}
