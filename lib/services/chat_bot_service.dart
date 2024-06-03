import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  late OpenAI openAI;
  final String kToken = 'sk-proj-bofrvC0NKYWbFXzBvFdJT3BlbkFJc95fuqr5951O8qR3ZZYh';
  final String systemPrompt = """
You are a personal plant assistant, called PlantPal!

PlantPal is an advanced AI-powered assistant designed to provide comprehensive information and assistance related to plants. Whether you're a seasoned gardener, a beginner plant parent, or simply curious about the world of flora, PlantPal is here to help. Below are the detailed functionalities and capabilities of PlantPal:

Plant Identification:

PlantPal utilizes state-of-the-art image recognition technology to accurately identify plants from uploaded photos. Users can upload images of plants they encounter in their surroundings, whether in their garden, on a hike, or at a friend's house.
Upon receiving an image, PlantPal will analyze it using deep learning algorithms trained on vast datasets of plant images. The system will then compare features such as leaf shape, flower morphology, and overall structure to a vast database of plant species.
PlantPal will provide users with the most likely identification of the plant in the image, including its common name, scientific name (genus and species), and relevant information such as preferred growing conditions, care tips, and potential uses (e.g., ornamental, culinary, medicinal).
Plant Care Guidance:

Users can ask PlantPal for personalized care guidance for specific plants they own or are interested in acquiring. This includes information on watering frequency, sunlight requirements, soil type, temperature preferences, pruning techniques, and pest control measures.
PlantPal takes into account the geographic location of the user to provide tailored recommendations based on local climate conditions, ensuring optimal plant care advice.
Plant Information Database:

PlantPal maintains an extensive database of plant species, including both common and rare varieties from around the world. Users can search this database by plant name, characteristics, or growing conditions to access detailed information on a wide range of plants.
Each plant entry in the database includes botanical descriptions, native habitats, cultivation history, interesting facts, and any cultural or symbolic significance associated with the plant.
Interactive Plant Q&A:

PlantPal offers a conversational interface where users can ask questions about plants in natural language. Whether it's inquiries about specific plant species, gardening techniques, plant diseases, or troubleshooting plant problems, PlantPal is equipped to provide informative and helpful responses.
The AI model underlying PlantPal is trained on vast corpora of plant-related texts, including botanical literature, gardening guides, academic papers, and online forums, ensuring a rich and diverse knowledge base.
Community Engagement:

PlantPal fosters a vibrant community of plant enthusiasts where users can share their experiences, ask for advice, and showcase their plant collections. The app includes features for users to interact with each other, such as forums, discussion threads, and photo sharing.
PlantPal encourages collaboration and knowledge sharing among its users, creating a supportive ecosystem for plant lovers of all levels of expertise.
Continuous Learning and Improvement:

PlantPal's AI model is continuously updated and refined based on user interactions, feedback, and new developments in the field of botany and horticulture. This ensures that the system remains up-to-date with the latest information and can provide accurate and relevant assistance to users.
Users are encouraged to provide feedback on the accuracy and usefulness of PlantPal's responses, helping to refine the system and improve the overall user experience over time.
With its advanced features, comprehensive plant database, and user-friendly interface, PlantPal is your indispensable companion for all things related to plants. Whether you're nurturing a green thumb or simply exploring the wonders of the botanical world, PlantPal is here to guide and inspire you on your plant journey!

Every output should only be in the strict format : " <User Response> // <Image Description if a image is uploaded> " . 
""";
  late ContextHandler _contextHandler;
 
  

  ChatBot() {
    openAI = OpenAI.instance.build(
      token: kToken,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 20),
      ),
      enableLog: true,
    );
    _contextHandler = ContextHandler(maxInputTokens: 1000, openAI: openAI);
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

      List<Map<String, dynamic>> previousMessages = _contextHandler.contentMessages;
      previousMessages.insert(0, {"role": "system", "content": systemPrompt});

      final request = ChatCompleteText(
        messages: previousMessages + currentMessage,
        maxToken: 200,
        model: ChatModelFromValue(model: 'gpt-4o'),
      );

      final response = await openAI.onChatCompletion(request: request);
      debugPrint('Chat completion response received');

      //_contextHandler.findAndAppendSimilarMessage("Brocolli"); this works great but just comment

      return _handleResponse(message, response?.choices[0].message?.content);
    } catch (e) {
      debugPrint('Error in _chatCompletion: $e');
      return null;
    }
  }

  String _handleResponse(Message message, String? response) {
    if (response == null) return "Error";

    final String imageDescription = response.split('//').length == 1 ? "" : response.split('//')[1];
    final String userResponse = response.split('//')[0];
    debugPrint('Handling response: $userResponse // $imageDescription');
    var m = Message(
      userName: message.userName,
      text: message.text,
      base64ImageUrl: message.base64ImageUrl != null
          ? base64Encode(Uint8List.fromList(message.base64ImageUrl!.codeUnits))
          : null,
      timeStamp: DateTime.now(),
      imageDescription: imageDescription,
    );
    _contextHandler.addMessage(m);

    m = Message(
      userName: "BOT",
      text: userResponse,
      base64ImageUrl: null,
      timeStamp: DateTime.now(),
      imageDescription: null,
    );

    _contextHandler.addMessage(m);

    return userResponse;
  }
}

class ContextHandler {
  List<Message> messages = [];
  final List<String> fakedb  =  [] ; 
  final List<List<double>> fakeEmbed = []; 
  int currentTokenCount = 0;
  final int maxInputTokens;
  final OpenAI openAI;

  ContextHandler({required this.maxInputTokens, required this.openAI});

  List<Map<String, dynamic>> get contentMessages {
    return messages.map((message) => message.contentMessage).toList();
  }

  void addMessage(Message m) async {
    debugPrint('Adding message: ${m.text}');
    messages.add(m);

    currentTokenCount += _calculateTokenCount(m.text) +
        _calculateTokenCount(m.base64ImageUrl) +
        _calculateTokenCount(m.timeStamp.toString()) +
        _calculateTokenCount(m.imageDescription);

    if (currentTokenCount * 1.3 > maxInputTokens - maxInputTokens) { // for debug
       await _storeInDatabase(m);
    }
  }

  int _calculateTokenCount(String? content) {
    if (content == null) return 0;
    return content.length ~/ 4;
  }

  int _calculateTotalTokenCount() {
    return messages.fold(0, (sum, message) =>
        sum + _calculateTokenCount(message.text) +
            _calculateTokenCount(message.base64ImageUrl) +
            _calculateTokenCount(message.timeStamp.toString()) +
            _calculateTokenCount(message.imageDescription));
  }


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

  Future<Message?> _vectorSearch(String searchString) async {
    try { 

      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Signed in anonymously as: ${userCredential.user?.uid}');

      debugPrint('Performing vector search');

      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('ext-firestore-vector-search-queryCallable');
      

      final response = await callable.call(<String, dynamic>{
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

  Future<void> findAndAppendSimilarMessage(String query) async {
    debugPrint('Finding and appending similar message for query: $query');

    final results = await _vectorSearch(query);
    if (results == null ){
       debugPrint("error");
       return ; 
    }

    messages.insert(0, results);
    debugPrint('Similar message appended: ${results.text}');

    return ; 
  }
}
