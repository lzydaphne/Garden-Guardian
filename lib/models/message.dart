
// class Message {
  
//   final String text;
//   final String userName;
//   final String? imageUrl;

//   // Constructor for Views or ViewModels
//   Message({
//     required this.text,
//     required this.userName,
//     this.imageUrl 
//   });

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is Message && runtimeType == other.runtimeType && userName == other.userName;

//   @override
//   int get hashCode => userName.hashCode;
// }

class Message {
  final String text;
  final String? base64ImageUrl;
  final String userName ; 
  final DateTime timeStamp ; 
  final String? imageDescription;
  String get role {
    return userName != "Bot" ? "user" : "assistant" ; 

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && userName == other.userName;

  @override
  int get hashCode => userName.hashCode;
}