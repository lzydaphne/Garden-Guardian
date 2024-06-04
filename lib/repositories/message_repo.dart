import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<Message>> streamViewMessages() { // all of the message in db with username != null (not system message)
    return _db
        .collection('user')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  } // TODO : filter message with username == null ( system message)

  Stream<List<Message>> streamContentMessages() { // all of the message in db 
    return _db
        .collection('user')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
  



  int currentTokenCount = 0; // TODO  : store to db in future 
  final int maxInputTokens = 0 ; // TODO  : store to db in future 

  void addMessage(Message m) async {
    debugPrint('Adding message: ${m.text}');
 
    currentTokenCount += _calculateTokenCount(m.text) +
        _calculateTokenCount(m.base64ImageUrl) +
        _calculateTokenCount(m.timeStamp.toString()) +
        _calculateTokenCount(m.imageDescription);

    if (currentTokenCount * 1.3 > maxInputTokens) { // for debug
       await _storeInDatabase(m);
    }
  }

  int _calculateTokenCount(String? content) {
    if (content == null) return 0;
    return content.length ~/ 4;
  }

  // int _calculateTotalTokenCount() {
  //   return messages.fold(0, (sum, message) =>
  //       sum + _calculateTokenCount(message.text) +
  //           _calculateTokenCount(message.base64ImageUrl) +
  //           _calculateTokenCount(message.timeStamp.toString()) +
  //           _calculateTokenCount(message.imageDescription));
  // }


  Future<void> _storeInDatabase(Message message) async {
  try {
    debugPrint('Storing message in database: ${message.text}');
    
    final HttpsCallable callable =  FirebaseFunctions.instance.httpsCallable('storeInDatabase');
    
    debugPrint('Callable created, waiting for response from database');

    final response = await callable.call(<String, dynamic>{
      'role': message.role,
      'text': message.text,
      'base64ImageUrl': message.base64ImageUrl,
      'timeStamp': message.timeStamp.toString(),
      'imageDescription': message.imageDescription,
      'stringtoEmbed': message.text + (message.imageDescription ?? '') + message.timeStamp.toString(),
    });

    debugPrint('Received response from database: ${response.data}');
  } catch (e) {
    debugPrint('Error storing message in database: $e');
  }
}

Future<void> findAndAppendSimilarMessage(String query) async {
    debugPrint('Finding and appending similar message for query: $query');

    final results = await _vectorSearch(query);
    if (results == null ){
       debugPrint("error");
       return ; 
    }

    //messages.insert(0, results); TODO add system message info to database
    
    debugPrint('Similar message appended: ${results.text}');

    return ; 
  }

Future<Message?> _vectorSearch(String searchString) async {
    try { 

      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Signed in anonymously as: ${userCredential.user?.uid}');

      debugPrint('Performing vector search');

      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('ext-firestore-vector-search-queryCallable');
      

      final response = await callable.call(<String, dynamic>{ // TODO : add a prefilter with username != null (don;t consider system message)
        'query': searchString,
        'limit': 1,
      });
      debugPrint('Vector search response: ${response.data}');

      debugPrint('Fetching message from Firestore with ID: ${response.data['ids'][0]}');
      final docSnapshot = await FirebaseFirestore.instance.collection('user').doc(response.data['ids'][0]).get();
    
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return Message(
          userName: data?['userName'] ?? '',
          text: data?['text'] ?? '',
          base64ImageUrl: data?['base64ImageUrl'] ?? '',
          timeStamp: DateTime.parse(data?['timeStamp'] ?? ''),
          imageDescription: data?['imageDescription'] ?? '',
        );
      }
      else{
        return null  ; 
      }
    }catch (e)
    {
      debugPrint('Error in vector search: $e');
    }
    return null;
    

  }




  
}