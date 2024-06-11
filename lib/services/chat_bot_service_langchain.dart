import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

// lib/services/chat_bot_service_langchain.dart

class ChatBotServiceLangChain extends ChangeNotifier {
  final ChatOpenAI _myChatModel;
  final OpenAIToolsAgent _agent;

  ChatBotServiceLangChain(String apiKey)
      : _myChatModel = ChatOpenAI(
          apiKey: apiKey,
          defaultOptions: const ChatOpenAIOptions(
            model: 'gpt-4o', // Specify the model you want to use
            temperature: 0.7, // You can adjust other parameters as needed
            maxTokens: 100,
          ),
        ),
        _agent = OpenAIToolsAgent.fromLLMAndTools(
          llm: ChatOpenAI(apiKey: apiKey),
          tools: [PlantIdentificationTool()],
          memory: ConversationBufferMemory(returnMessages: true),
        );

  Future<String> processImage(String imagePath) async {
    ImageHandler imageHandler = ImageHandler();
    final base64Image = await imageHandler.convertImageToBase64(imagePath);
    if (base64Image == null) {
      return 'Error converting image';
    }

    final executor = AgentExecutor(agent: _agent);
    final ChainValues input = {'imagePath': base64Image};
    print('Input: $input');

    final ChainValues result;
    try {
      result = await executor.invoke(input);
    } catch (e) {
      print('Error: $e');
      return 'Error processing executor';
    }

    // Assuming the output key is 'output' based on the default output key in your chain
    final String output =
        result['output']?.toString() ?? 'Error processing image';

    // print the result
    print('Result: $output');
    return output;
  }

  Future<String> processMessage(String message) async {
    // Add your logic here to process text messages if needed
    // Create the prompt with the message
    final messages = [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.humanText(message),
    ];
    final prompt = PromptValue.chat(messages);

    try {
      // Invoke the model with the prompt
      final res = await _myChatModel.invoke(prompt);

      // Extract the response text
      final responseText = res.output.content;
      // Print the result
      print('Result: $responseText');
      return responseText;
    } catch (e) {
      print('Error: $e');
      return 'Error processing message';
    }
    // return "Text message processing not implemented.";
  }
}

class ImageHandler {
  Future<String?> convertImageToBase64(String? imagePath) async {
    if (imagePath == null) return null;
    try {
      debugPrint('Converting image to base64: $imagePath');
      final bytes = await readImageAsBytes(imagePath);
      if (bytes == null) {
        // print('Failed to load image');
        throw Exception("Failed to load image");
      }
      final base64String = base64Encode(bytes);
      final mimeType = lookupMimeType(imagePath, headerBytes: bytes);
      debugPrint('MIME type: $mimeType');
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('Error in convertImageToBase64: $e');
      return 'Error 123';
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

// PlantIdentificationTool definition
base class PlantIdentificationTool extends Tool<String, ToolOptions, String> {
  PlantIdentificationTool()
      : super(
          name: 'PlantIdentifier',
          description: 'Identifies plant species and provides care information',
          inputJsonSchema: {
            'type': 'object',
            'properties': {
              'imagePath': {
                'type': 'string',
                'description': 'Base64 encoded image string',
              },
            },
            'required': ['imagePath'],
          },
        );

  @override
  Future<String> invokeInternal(
    final String imagePath, {
    final ToolOptions? options,
  }) async {
    final species = 'Ficus lyrata';
    final today = DateTime.now();
    final wateringCycle = 7;
    final fertilizationCycle = 30;
    final pruningCycle = 60;

    final response = '''
    Plant Species: $species
    Planting Date: ${today.toIso8601String()}
    Watering Cycle: Every $wateringCycle days
    Fertilization Cycle: Every $fertilizationCycle days
    Pruning Cycle: Every $pruningCycle days
    ''';

    final plantInfo = {
      'species': species,
      'plantingDate': today.toIso8601String(),
      'wateringCycle': wateringCycle,
      'fertilizationCycle': fertilizationCycle,
      'pruningCycle': pruningCycle,
      'nextWateringDay':
          today.add(Duration(days: wateringCycle)).toIso8601String(),
      'nextFertilizationDay':
          today.add(Duration(days: fertilizationCycle)).toIso8601String(),
      'nextPruningDay':
          today.add(Duration(days: pruningCycle)).toIso8601String(),
    };

    final plantInfoJson = jsonEncode(plantInfo);
    final file = File('plant_info.json');
    await file.writeAsString(plantInfoJson);

    return response;
  }

  @override
  String getInputFromJson(final Map<String, dynamic> json) {
    return json['imagePath'] as String;
  }
}

// // Define the tool for plant species identification and information retrieval
// base class PlantIdentificationTool extends Tool<String, ToolOptions, String> {
//   PlantIdentificationTool()
//       : super(
//           name: 'PlantIdentifier',
//           description: 'Identifies plant species and provides care information',
//           inputJsonSchema: {
//             'type': 'object',
//             'properties': {
//               'imagePath': {
//                 'type': 'string',
//                 'description': 'Path to the plant image',
//               },
//             },
//             'required': ['imagePath'],
//           },
//         );

//   @override
//   Future<String> invokeInternal(
//     final String imagePath, {
//     final ToolOptions? options,
//   }) async {
//     // Simulate plant identification using a model
//     final species = 'Ficus lyrata'; // This should come from the model's output
//     final today = DateTime.now();
//     final wateringCycle = 7; // in days
//     final fertilizationCycle = 30; // in days
//     final pruningCycle = 60; // in days

//     // Construct the response message
//     final response = '''
//     Plant Species: $species
//     Planting Date: ${today.toIso8601String()}
//     Watering Cycle: Every $wateringCycle days
//     Fertilization Cycle: Every $fertilizationCycle days
//     Pruning Cycle: Every $pruningCycle days
//     ''';

//     // Store the information locally (simulated)
//     final plantInfo = {
//       'species': species,
//       'plantingDate': today.toIso8601String(),
//       'wateringCycle': wateringCycle,
//       'fertilizationCycle': fertilizationCycle,
//       'pruningCycle': pruningCycle,
//       'nextWateringDay':
//           today.add(Duration(days: wateringCycle)).toIso8601String(),
//       'nextFertilizationDay':
//           today.add(Duration(days: fertilizationCycle)).toIso8601String(),
//       'nextPruningDay':
//           today.add(Duration(days: pruningCycle)).toIso8601String(),
//     };

//     final plantInfoJson = jsonEncode(plantInfo);
//     final file = File('plant_info.json');
//     await file.writeAsString(plantInfoJson);

//     return response;
//   }

//   @override
//   String getInputFromJson(final Map<String, dynamic> json) {
//     return json['imagePath'] as String;
//   }
// }

// void main() async {
//   // Initialize the chat model with OpenAI API key
//   final myChatModel =
//       ChatOpenAI(apiKey: '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');
//   final tools = [PlantIdentificationTool()];

//   // Setup the agent with LLM and tools
//   final agent = OpenAIToolsAgent.fromLLMAndTools(
//     llm: myChatModel,
//     tools: tools,
//     memory: ConversationBufferMemory(returnMessages: true),
//   );

//   // Function to add a new plant using the agent
//   Future<void> addNewPlant(String imagePath) async {
//     final executor = AgentExecutor(agent: agent);
//     final result = await executor.run(imagePath);
//     print(result); // This should print the plant care information
//   }

//   // Simulate adding a new plant with an image path
//   await addNewPlant('path/to/plant/image.jpg');
// }
