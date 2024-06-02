// import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/services/chat_bot_service.dart';
// import 'package:flutter_app/repositories/message_repo.dart';

class AllMessagesViewModel with ChangeNotifier {
  final ChatBot chatService; 
  AllMessagesViewModel({required this.chatService}){
    _messages.add(Message(text: "Hi , how can I help you", userName: "BOT",timeStamp: DateTime.now()));
  }
 
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  Future<void> addMessage(Message newMessage) async {
    if (_messages.isNotEmpty ){ // _messsage empty then welcome user
      _messages.add(newMessage) ; 
      notifyListeners();
    } 
    final response = await chatService.doResponse(newMessage);
    _messages.add(Message(text: response, userName: "BOT",timeStamp: DateTime.now())) ; 
    notifyListeners();
    return ;
  }
}
