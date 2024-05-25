
class Message {
  
  final String text;
  final String userName;
  final String? imageUrl;

  // Constructor for Views or ViewModels
  Message({
    required this.text,
    required this.userName,
    this.imageUrl 
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && userName == other.userName;

  @override
  int get hashCode => userName.hashCode;
}
