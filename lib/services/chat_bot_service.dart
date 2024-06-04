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

    final String imageDescription = response.split('//').length == 1 ? "" : response.split('//')[1];
    final String userResponse = response.split('//')[0];
    debugPrint('Handling response: $userResponse // $imageDescription');

    var m = Message(
      role: message.role,
      text: message.text,
      base64ImageUrl: message.base64ImageUrl,
      imageDescription: imageDescription,
    );

    await _messageRepository.addMessage(m);

    //TODO : Implement the memory retrieval logic , and produce the query string 
    await _messageRepository.findAndAppendSimilarMessage("Brocolli");

    // Redo the chatcompletion , with the same question again 

    //remember now the new system message added is not in the knowledge scope of gpt, since the thing we sent to GPT hadn't contained the retricve memory system message yet

    


    m = Message(
      role: "assistant",
      text: userResponse,
      base64ImageUrl: null,
      timeStamp: DateTime.now(),
      imageDescription: null,
    );

    await _messageRepository.addMessage(m);

    return userResponse;
  
  }
}


