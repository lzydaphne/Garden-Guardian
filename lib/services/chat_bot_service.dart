import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chat_gpt_sdk/src/model/embedding/enum/embed_model.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';


class ChatBot extends ChangeNotifier {
  late OpenAI openAI;
  final kToken = 'sk-proj-bofrvC0NKYWbFXzBvFdJT3BlbkFJc95fuqr5951O8qR3ZZYh'; // Enter OpenAI API_KEY
  final systemPrompt = """
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
 late ContextHandler _contextHandler ; 

  ChatBot() {
    openAI = OpenAI.instance.build(
      token: kToken,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 20),
      ),
      enableLog: true,
    );
    _contextHandler = ContextHandler(maxInputTokens : 1000,openAI : openAI) ; 
  }

 

  Future<String> doResponse(Message userInp) async {
    try {
      final responseText = await _chatCompletion(userInp);
      return responseText ?? 'Error';
    } catch (e) {
      debugPrint('Error in doResponse: $e');
      return 'Error';
    }
  }

  Future<String?> _chatCompletion(Message message) async {
    try {
      dynamic contentMessage; 
    
      if (message.imageUrl != null) {
        
        final base64Image = await _convertImageToBase64(message.imageUrl!);
      
        contentMessage = [
          {"type": "text", "text": message.text},
          {"type": "image_url", "image_url":{"url":base64Image}},
        ];
      } else {
        contentMessage = [{"type": "text", "text": message.text}];
      }

      List<Map<String, dynamic>> previousMessages = _contextHandler.contentMessages ; 
      previousMessages.insert(0, {"role": "system", "content": systemPrompt});

      final request = ChatCompleteText(
        messages: previousMessages + contentMessage ,
        maxToken: 200,
        model: ChatModelFromValue(model: 'gpt-4o'),
      );

      final response = await openAI.onChatCompletion(request: request);

      return _handleResponse(message,response?.choices[0].message?.content);
    } catch (e) {
      debugPrint('Error in _chatCompletion: $e');
      return null;
    }
  }

  String _handleResponse(Message message, String? response) {
    if (response == null )return "Error "; 

    final String imageDescription = response.split('//')[1];
    final String userResponse = response.split('//')[0];
    final chatMessage = ChatMessage(
      role: 'user',
      text: message.text,
      base64ImageUrl: message.imageUrl != null ? base64Encode(Uint8List.fromList(message.imageUrl!.codeUnits)) : null,
      timeStamp: DateTime.now(),
      imageDescription: imageDescription,
    );
    _contextHandler.addMessage(chatMessage.role, chatMessage.text, chatMessage.base64ImageUrl, chatMessage.timeStamp, chatMessage.imageDescription!);

    return userResponse ; 
  }

  Future<String> _convertImageToBase64(String imagePath) async {
    try {
      debugPrint(imagePath);
      final bytes = await readImageAsBytes(imagePath);
      if (bytes == null) {
        throw Exception("Failed to load image");
      }
      final base64String = base64Encode(bytes);
      final mimeType = lookupMimeType(imagePath, headerBytes: bytes);
      debugPrint(mimeType);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('Error in _convertImageToBase64: $e');
      return 'Error';
    }
  }

  Future<Uint8List?> readImageAsBytes(String url) async {
    try {
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
}


class ContextHandler {
  List<ChatMessage> messages = [];
  int currentTokenCount = 0;
  final int maxInputTokens;
  final OpenAI openAI;

  ContextHandler({required this.maxInputTokens, required this.openAI});

  void addMessage(String role , String text, String? base64ImageUrl, DateTime timeStamp,String imageDescription) {
    messages.add(ChatMessage(role: role , text: text, base64ImageUrl: base64ImageUrl,timeStamp: timeStamp, imageDescription: imageDescription));

    // Calculate tokens for the new messages
    currentTokenCount +=  _calculateTokenCount(text) + _calculateTokenCount(base64ImageUrl) + _calculateTokenCount(timeStamp as String) + _calculateTokenCount(imageDescription) ; 

    // Check if tokens exceed the threshold
    if (currentTokenCount * 1.3 > maxInputTokens) {
      _embedAndStoreMessages();
    }
  }

  int _calculateTokenCount(String? content) {
    // A simple approximation of token count
    if (content == null )return 0 ; 
    return content.length ~/ 4;
  }

  void _embedAndStoreMessages() async {
    int half = messages.length ~/ 2;
    
    List<ChatMessage> messagesToEmbed = messages.sublist(0, half);

    List<List<double>> embeddings = [];
    for (var message in messagesToEmbed) {
      String combinedContent = '${message.text}${message.imageDescription}${message.timeStamp}';

      final request = EmbedRequest(
        model: TextEmbeddingAda002EmbedModel(),
        input: combinedContent,
        dimensions: 1525,
      );

      final response = await openAI.embed.embedding(request);
      embeddings.add(response.data.last.embedding);
    }

    _storeInDatabase(embeddings); 

    // Remove embedded messages and adjust token count
    messages = messages.sublist(half);
    currentTokenCount = _calculateTotalTokenCount();
  }

  int _calculateTotalTokenCount() {
    return messages.fold(0, (sum, message) => sum + _calculateTokenCount(message.text) + _calculateTokenCount(message.base64ImageUrl) + _calculateTokenCount(message.timeStamp as String) + _calculateTokenCount(message.imageDescription));
  }

  void _storeInDatabase(List<List<double>> embedding) {
    // Implement the logic to store embeddings in your long-term memory database
    // For example:
    // Database.store('embeddings', embedding);


    // Should implement cloud functions in index.js , use http call to get service
  }

  void vectorSearch(List<double> queryEmbedding){


     // Should implement cloud functions in index.js , use http call to get service
    return null ; 

  }

  List<Map<String,dynamic>> get contentMessages {
   List<Map<String,dynamic>> contentMessages  =  messages.map((message) {
    return message.contentMessage ; 
  }).toList();
  return contentMessages ; 
    

  }


  Future<void> findAndAppendSimilarMessage(String query) async {
    // Step 1: Embed the query string
    final request = EmbedRequest(
      model: TextEmbeddingAda002EmbedModel(),
      input: query,
    );

    final response = await openAI.embed.embedding(request);
    final queryEmbedding = response.data.last.embedding;

    final results = vectorSearch(queryEmbedding);
    
    if (results.docs.isEmpty) {
      debugPrint('No similar documents found.');
      return;
    }

    final mostSimilarDoc = results.docs.first;

    // Step 3: Retrieve the document and convert it into a Message object
    final data = mostSimilarDoc.data();
    final similarMessage = ChatMessage(
      role: data['role'] ?? '', 
      text: data['text'] ?? '',
      base64ImageUrl: data['base64ImageUrl'] ?? '',
      timeStamp : data['timeStamp'] ?? '', 
      imageDescription: data['imageDescription'] ?? '', 
    );

    // Step 4: Append the retrieved Message object to the head of the list
    messages.insert(0, similarMessage);
  }
}



class ChatMessage {
  final String text;
  final String? base64ImageUrl;
  final String role; 
  final DateTime timeStamp ; 
  final String? imageDescription;

  ChatMessage({required this.role , required this.text, required this.base64ImageUrl , required this.timeStamp,this.imageDescription});

  Map<String,dynamic>  get contentMessage {
    List<Map<String,dynamic>> contentList = [];

    if (text.isNotEmpty) {
      contentList.add({"type": "text", "text": text});
    }
    if (base64ImageUrl != null) {
      contentList.add({"type": "image_url", "image_url": {"url": "$base64ImageUrl"}});
    }

    return {"role": role, "content": contentList} ; 
  }
}


// embedd with image description