import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String role ;
  final String text;
  final String? base64ImageUrl;
  final String? imageDescription;
  final DateTime? timeStamp ; 
   
   

  Message({required this.role,required this.text, this.base64ImageUrl,this.imageDescription,this.timeStamp});

  Map<String,dynamic>  get contentMessage {
    List<Map<String,dynamic>> contentList = [];

    if (text.isNotEmpty) {
      contentList.add({"type": "text", "text": text});
    }
    if (base64ImageUrl != null) {
      contentList.add({"type": "image_url", "image_url": {"url": "$base64ImageUrl"}});
    }

    return {"role": role , "content": contentList} ;  // need modify
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      role: map['role'],
      text: map['text'],
      base64ImageUrl: map['base64ImageUrl'] == '' ? null : map['base64ImageUrl'],
      imageDescription: map['imageDescription']== '' ? null : map['imageDescription'],
      timeStamp: map['timeStamp'] == null ? null : DateTime.parse((map['timeStamp'] as Timestamp).toDate().toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'text': text,
      'base64ImageUrl': base64ImageUrl,
      'imageDescription': imageDescription,
      'timeStamp': FieldValue.serverTimestamp(),
      'stringtoEmbed' : text + (imageDescription ?? '') + timeStamp.toString() , 
    };
  }


  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is Message && runtimeType == other.runtimeType && userName == other.userName;

  // @override
  // int get hashCode => userName.hashCode;
}