// import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/services/chat_bot_service.dart';
// import 'package:flutter_app/repositories/message_repo.dart';

class AllMessagesViewModel with ChangeNotifier {
  final ChatBot chatService;
  AllMessagesViewModel({required this.chatService}) {
    _messages.add(Message(text: "Hi , how can I help you", userName: "BOT"));
  }

  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  Future<void> addMessage(Message newMessage) async {
    if (_messages.isNotEmpty) {
      // _messsage empty then welcome user
      _messages.add(newMessage);
      notifyListeners();
    }
    await chatService.doResponse(newMessage, this);
    // final response = await chatService.doResponse(newMessage, this);
    // _messages.add(Message(text: response, userName: "BOT"));
    // notifyListeners();
    return;
  }

  // Method to access _messages within chatService
  List<Message> getMessages() {
    return _messages;
  }

  // Method to set the messages list directly
  void setMessages(List<Message> newMessages) {
    _messages.clear();
    _messages.addAll(newMessages);
    notifyListeners();
  }

  // Method to add a message from chatService
  void addBotMessage(String text) {
    _messages.add(Message(text: text, userName: "BOT"));
    notifyListeners();
  }
}
