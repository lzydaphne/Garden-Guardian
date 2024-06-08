import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_app/repositories/message_repo.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';


class ImageHandler {
  Future<String?> convertImageToBase64(String? imagePath) async {
    if (imagePath == null) return null;
    try {
      debugPrint('Converting image to base64: $imagePath');
      final bytes = await readImageAsBytes(imagePath);
      if (bytes == null) {
        throw Exception("Failed to load image");
      }
      final base64String = base64Encode(bytes);
      final mimeType = lookupMimeType(imagePath, headerBytes: bytes);
      debugPrint('MIME type: $mimeType');
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('Error in convertImageToBase64: $e');
      return 'Error';
    }
  }

  Future<Uint8List?> readImageAsBytes(String url) async {
    try {
      debugPrint('Reading image as bytes from URL: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('Failed to load image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }

  // TODO : compress image for file space
}

class ChatBot extends ChangeNotifier {
  final MessageRepository _messageRepository ; 
  StreamSubscription<List<Message>>? _messagesSubscription;
  List<Message> windowMessages = [];  
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;


  late OpenAI openAI;
  final String kToken = 'sk-proj-bofrvC0NKYWbFXzBvFdJT3BlbkFJc95fuqr5951O8qR3ZZYh';
  final String systemPrompt = """
You are a personal plant assistant, called PlantPal!


And you support the follwing three features :

Feature 1 : If users uploaded an image about plants , you can accurately identify plants from uploaded photos by compare features such as leaf shape, flower morphology, and overall structure by your knowledge or supported deep learning model.
THe reponse format of Feature 1 : If Feature 1 is used , then you should generate a detailed description and keywords for future embedding to find this picture.

Feature 2. You have a database that stores pass conversations between you and the user. If you encounter questions by user that requires pass conversation informations between you and user after checking the past user prompts and provided system prompts of retrieved memory from database, you can generate a query to search for required pass conversation contents in the database.
The reponse format of Feature 2 : If Feature 2 is used , then you should generate a query contains keywords or descriptions for later embedding search in the pass conversation database. 
Reminder for Feature 2 : You shouldn't do a query if you found suitable information from the retrieved memory system prompts from the database or from the past user prompts or the system! Also if the message before the current user prompt is the retrieved memory system prompts or the system prompt message that says "The database is empty , can't retrieved information of pass conversation." from the database , it means you already done query correspond to the current user prompt already , so you can't generate a query again , you only can reference informations in your context window and figure out the response when using Feature 3, if you really couldn't figure out what the user is mentioning, ask if the user can provide more informations for you to search your memory database again . 

Feature 3. You can answer the question asked by user in a detailed way.
THe reponse format of Feature 3 : If Feature 3 is used , then you should genrate a detailed response to the user's question, you can use the information of other features mentioned above to support your response. 

Every time you recieved an user input, you analyze the input , and choose to use at least one of the features above to respond the input(you should choose as many features that is suitable to solve the problem),  every time generate the response in the strict format of feature responses seperated by "//":

"<Response of Feature 1 if feature 1 is used else output '@' here>  // <Response of Feature 2 if feature 2 is used else output '@' here> // <Response of Feature 3 if Feature 3 is used else output '@' here>"

""";

  
  int _calculateTokenCount(String? content) {
    if (content == null) return 0;
    return content.length ~/ 4;
  }
  final _maxToken = 100  ;


  ChatBot({MessageRepository? messageRepository})
      : _messageRepository = messageRepository ?? MessageRepository() {

    // _messagesSubscription = _messageRepository.streamContentMessages().listen(
    //   (messages) {
    //     _isInitializing = false;
    //     int currentTokenCount = 0;

    //   windowMessages = messages.takeWhile((message) {
    //     int messageTokenCount = _calculateTokenCount(message.text) +
    //         _calculateTokenCount(message.base64ImageUrl) +
    //         _calculateTokenCount(message.timeStamp.toString()) +
    //         _calculateTokenCount(message.imageDescription);

    //     if (currentTokenCount + messageTokenCount > _maxToken) {
    //       return false;
    //     }

    //   currentTokenCount += messageTokenCount;
    //   return true;
    //   }
      
    // ).toList();
    //     notifyListeners();


    try {
      debugPrint('CB initializing');      
      _messagesSubscription = _messageRepository.streamContentMessages().listen(
        (messages) {
          _isInitializing = false;
          windowMessages = messages;
          notifyListeners();
        },
        onError: (error) {
          debugPrint("Stream error: $error");
          // Handle stream error appropriately
        },
      );
      debugPrint('CB  initialize complete');
    } catch (e, stackTrace) {
      debugPrint("Initialization error: $e");
      debugPrint("Stack trace: $stackTrace");
    }

    openAI = OpenAI.instance.build(
      token: kToken,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 20),
      ),
      enableLog: true,
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<String> doResponse(Message userInp) async {
    try {
      debugPrint('Generating response for user input');
      final responseText = await _chatCompletion(userInp);
      return responseText ?? 'Error';
    } catch (e) {
      debugPrint('Error in doResponse: $e');
      return 'Error';
    }
  }

  Future<String?> _chatCompletion(Message message) async {
    try {
      debugPrint('Starting chat completion');
      dynamic contentMessage;

      if (message.base64ImageUrl != null) {
        contentMessage = [
          {"type": "text", "text": message.text},
          {"type": "image_url", "image_url": {"url": message.base64ImageUrl}},
        ];
      } else {
        contentMessage = [{"type": "text", "text": message.text}];
      }

      final currentMessage = [{"role": "user", "content": contentMessage}] ; 

      List<Map<String, dynamic>> previousMessages = windowMessages.map((windowMessage)=>windowMessage.contentMessage).toList();
      previousMessages.insert(0, {"role": "system", "content": systemPrompt});
      
      final request = ChatCompleteText(
        messages: previousMessages + currentMessage,
        maxToken: 200,
        model: ChatModelFromValue(model: 'gpt-4o'),
      );

      final response = await openAI.onChatCompletion(request: request);
      debugPrint('Chat completion response received');
      
      
      return await _handleResponse(message, response?.choices[0].message?.content);
    } catch (e) {
      debugPrint('Error in _chatCompletion: $e');
      return null;
    }
  }

  List<Map<String, dynamic>> get contentMessages {
    return windowMessages.map((message) => message.contentMessage).toList();
  }


  Future<String> _handleResponse(Message message, String? response) async {
    if (response == null) return "Error";
   
    debugPrint(response);
    final String needRetrieval = response.split('//')[1].contains('@') ? '' : response.split('//')[1];
    final String imageDescription = response.split('//')[0].contains('@') ? '' : response.split('//')[0];
    final String userResponse = response.split('//')[2].contains('@') ? '' : response.split('//')[2];
    debugPrint('Handling response: $userResponse // $imageDescription');

    var m = Message(
      role: message.role,
      text: message.text,
      base64ImageUrl: message.base64ImageUrl,
      imageDescription: imageDescription,
    );

    await _messageRepository.addMessage(m);
    debugPrint(response);
    if(!needRetrieval.contains('@')) {
      await _messageRepository.findAndAppendSimilarMessage(needRetrieval);
       m = Message(
      role: "assistant",
      text: await _chatCompletion2(m) as String,
      base64ImageUrl: null,
      timeStamp: DateTime.now(),
      imageDescription: null,
    );
     
       // Redo the chatcompletion , with the same question again 
        //remember now the new system message added is not in the knowledge scope of gpt, since the thing we sent to GPT hadn't contained the retricve memory system message yet
      
    }else{
      m = Message(
      role: "assistant",
      text: userResponse,
      base64ImageUrl: null,
      timeStamp: DateTime.now(),
      imageDescription: null,
    );
    }
    await _messageRepository.addMessage(m);

   

    return userResponse;
  
  }
  Future<String?> _chatCompletion2(Message message) async {
    try {
      debugPrint('Starting chat completion');
      dynamic contentMessage;

      if (message.base64ImageUrl != null) {
        contentMessage = [
          {"type": "text", "text": message.text},
          {"type": "image_url", "image_url": {"url": message.base64ImageUrl}},
        ];
      } else {
        contentMessage = [{"type": "text", "text": message.text}];
      }

      final currentMessage = [{"role": "user", "content": contentMessage}] ; 

      List<Map<String, dynamic>> previousMessages = windowMessages.map((windowMessage)=>windowMessage.contentMessage).toList();
      previousMessages.insert(0, {"role": "system", "content": systemPrompt});

      final request = ChatCompleteText(
        messages: previousMessages + currentMessage,
        maxToken: 200,
        model: ChatModelFromValue(model: 'gpt-4o'),
      );

      final response = await openAI.onChatCompletion(request: request);
      debugPrint('Chat completion response received');
      
      
      return response?.choices[0].message?.content.split('//')[2];
    } catch (e) {
      debugPrint('Error in _chatCompletion: $e');
      return null;
    }
  }
}


