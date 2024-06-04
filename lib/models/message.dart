class Message {
  final String text;
  final String? base64ImageUrl;
  final String? userName ; 
  final DateTime timeStamp ; 
  final String? imageDescription;
  String get role {
    if (userName == null)
    {
      return "system" ; 
    }
    return userName != "BOT" ? "user" : "assistant" ; 

  }

  Message({required this.userName , required this.text, this.base64ImageUrl , required this.timeStamp,this.imageDescription});

  Map<String,dynamic>  get contentMessage {
    List<Map<String,dynamic>> contentList = [];

    if (text.isNotEmpty) {
      contentList.add({"type": "text", "text": text});
    }
    if (base64ImageUrl != null) {
      contentList.add({"type": "image_url", "image_url": {"url": "$base64ImageUrl"}});
    }

    return {"role": role , "content": contentList} ; 
  }

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      text: map['text'],
      base64ImageUrl: map['base64ImageUrl'] == '' ? null : map['base64ImageUrl'],
      userName: map['role'],
      timeStamp: DateTime.parse(map['timeStamp']),
      imageDescription: map['imageDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'base64ImageUrl': base64ImageUrl,
      'role': role,
      'timeStamp': timeStamp.toString(),
      'imageDescription': imageDescription,
    };
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && userName == other.userName;

  @override
  int get hashCode => userName.hashCode;
}