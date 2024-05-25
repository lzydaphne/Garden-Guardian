
import 'package:flutter_app/models/message.dart';

class MessageRepository {
  List<Message> messageList = [] ; 

  addMessage(Message message){
    messageList.add(message);
  }
}
