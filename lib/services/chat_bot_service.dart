import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_app/repositories/message_repo.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_app/services/tool.dart';
// import 'package:flutter_app/view_models/all_messages_vm.dart';
import 'package:flutter_app/repositories/plant_repo.dart';
import 'package:flutter_app/repositories/appUser_repo.dart';

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
}

class ChatBot extends ChangeNotifier {
  final MessageRepository _messageRepository;
  final PlantRepository _plantRepository = PlantRepository();
  final ImageHandler imageHandler = ImageHandler();
  StreamSubscription<List<Message>>? _messagesSubscription;
  List<Message> windowMessages = [];
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  late OpenAI openAI;
  late ThreadRequest threadRequest;
  late ThreadResponse threadCreate;

  String kToken = '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';

  String systemPrompt = """
You are Garden Gurdian, an advanced AI-powered assistant designed to provide concise and comprehensive information and assistance related to plants. It is specifically tailored for total beginners. Below are the 3 functionalities and capabilities of Garden Gurdian, you should analyze the user input and provide the appropriate response with EXACTLY one of the following functionalities:

1. When the user inputs a new plant image that is not in the database, identify the plant species and provide care guidance:
    - Include species identification, planting date (today), watering cycle, fertilization cycle, and pruning cycle.
    - In the beginning, you should respond some necessary information about the plant
      - species, 
      - planting date, 
      - watering cycle, 
      - fertilization cycle, 
      - pruning cycle.
      - Next Watering Date
      - Next Fertilization Date
      - Next Pruning Date
    - Then Ask the user for a nickname for the plant and store all related information without asking again.
    - Call the "add_new_plant" function with the gathered information.

2. When the user updates that they have watered, fertilized, or pruned a specific plant, call "counting_goal" tool function:
    - Calculate and provide the next watering, fertilization, or pruning date and response.
      - Your response should contain at least one of the following: Next Watering Date, Next Fertilization Date, Next Pruning Date. Depend on the user's input.
      - Your response need not contain other information (species, nickname, watering cycle, fertilization cycle, pruning cycle) unless explicitly asked.
    - When the user inputs such as "i watered the plant today" , you should call the "counting_goal" function with the "watering" action.
    - Store the "last care date" that user mentioned in the format 'yyyy-MM-dd'.
      - Your response should contain "last care date" that user mentioned.
    - Do not provide additional information unless explicitly asked.
3. When the user inputs their feelings or thoughts about the plant:
    - Provide a positive and encouraging response to the user's feelings.
    - Include a concise SINGLE bullet point of a fun fact or interesting tidbit about the plant to engage the user.
    - Encourage the user to continue caring for the plant and offer additional tips or advice if needed.
    - Be concise and to the point. Do not provide additional information unless explicitly asked.

4. When the assistant can't remember the context or previous interactions:
    - Generate a query string for several kinds of possible keywords included in the pass messages.
    - Call the "find_similar_message" function with the query string to search for message that matches the keywords.
    - The "find_similar_message" function returns the message text of the pass conversation with user.
    - You can use the return pass conversation of the "find_similar_message" function to support your respond to the user's question.

5. For any other user inputs:
    - Provide short, clear, and direct answers.
    - Avoid giving additional information unless explicitly asked.

Remember to keep responses brief and focused on the user's query, and a little blend of fun and humor.
""";

  String imagesystemPrompt = """
You are a image analyzer , you will receive a user input message of a text and a image

- You will need to analyze the image and give very detailed description about the image.
- Check the user's input text if there is additional information needed about the image and add in the image description output.
- You should give detailed description with all the necessary keywords included in the description.

""";

  final tools = [
    {
      "type": "function",
      "function": {
        "name": "add_new_plant",
        "description":
            "Use this function to add a new plant and get related information.",
        "parameters": {
          "type": "object",
          "properties": {
            "species": {
              "type": "string",
              "description": "The specific species of the plant."
            },
            "wateringCycle": {
              "type": "integer",
              "description": "The watering cycle of the plant in days."
            },
            "fertilizationCycle": {
              "type": "integer",
              "description": "The fertilization cycle of the plant in days."
            },
            "pruningCycle": {
              "type": "integer",
              "description": "The pruning cycle of the plant in days."
            }
          },
          "required": [
            "species",
            "wateringCycle",
            "fertilizationCycle",
            "pruningCycle"
          ]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "counting_goal",
        "description":
            "Handles user behavior counting and calculates the next care dates for watering, fertilization, and pruning based on the planting date and cycles.",
        "parameters": {
          "type": "object",
          "properties": {
            "user": {
              "type": "object",
              "description":
                  "The appUser object containing user information and counters.",
              "properties": {
                "cnt_watering": {
                  "type": "integer",
                  "description": "The count of watering actions by the user."
                },
                // "cnt_plantNum": {
                //   "type": "integer",
                //   "description":
                //       "The count of plant numbers handled by the user."
                // },
                // "cnt_plantType": {
                //   "type": "integer",
                //   "description":
                //       "The count of different plant types handled by the user."
                // },
                // "cnt_drink": {
                //   "type": "integer",
                //   "description": "The count of drink actions by the user."
                // }
              },
              "required": [
                "cnt_watering"
                // "cnt_plantNum",
                // "cnt_plantType",
                // "cnt_drink"
              ]
            },
            // "behavior": {
            //   "type": "string",
            //   "description": "The behavior performed by the user."
            // },
            "lastActionDate": {
              "type": "string",
              "description":
                  "The lastAction(water/fertilize/prune) Date of the plant in the format of 'yyyy-MM-dd'."
            },
            "wateringCycle": {
              "type": "integer",
              "description": "The watering cycle of the plant in days."
            },
            "fertilizationCycle": {
              "type": "integer",
              "description": "The fertilization cycle of the plant in days."
            },
            "pruningCycle": {
              "type": "integer",
              "description": "The pruning cycle of the plant in days."
            }
          },
          "required": [
            "user",
            // "behavior",
            "lastActionDate",
            "wateringCycle",
            "fertilizationCycle",
            "pruningCycle"
          ]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "find_similar_message",
        "description":
            "Searches the database for past conversation contents related to the current query and appends them to the current thread.",
        "parameters": {
          "type": "object",
          "properties": {
            "query": {
              "type": "string",
              "description":
                  "The current query or context the assistant needs help with."
            }
          },
          "required": ["query"]
        }
      }
    }
  ];

  int _calculateTokenCount(String? content) {
    if (content == null) return 0;
    return content.length ~/ 4;
  }

  final _maxToken = 100;

  ChatBot({MessageRepository? messageRepository})
      : _messageRepository = messageRepository ?? MessageRepository() {
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
        },
      );
      debugPrint('CB initialize complete');
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
    threadRequest = ThreadRequest();
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
      dynamic contentMessage;
      bool isImage = false;
      var CCrequestImage;
      String? base64Image;

      if (message.base64ImageUrl != null) {
        base64Image =
            await imageHandler.convertImageToBase64(message.base64ImageUrl!);
        isImage = true;

        contentMessage = [
          {"type": "text", "text": message.text},
          {
            "type": "image_url",
            "image_url": {"url": base64Image}
          }
        ];

        // handle the another model of image description

        final imageMessage = [
          {"role": "user", "content": contentMessage}
        ];
        List<Map<String, dynamic>> sysMessages = [
          {"role": "system", "content": imagesystemPrompt}
        ];
        debugPrint('Image Message: ${sysMessages + imageMessage}');

        CCrequestImage = ChatCompleteText(
          messages: sysMessages + imageMessage,
          maxToken: 200,
          model: ChatModelFromValue(model: 'gpt-4o'),
          //     tools: tools,
          //     toolChoice: "auto"
        );
      } else {
        contentMessage = [
          {"type": "text", "text": message.text}
        ];
      }

      final currentMessage = [
        {"role": "user", "content": contentMessage}
      ];

      List<Map<String, dynamic>> previousMessages = windowMessages
          .map((windowMessage) => windowMessage.contentMessage)
          .toList();
      previousMessages.insert(0, {"role": "system", "content": systemPrompt});

      final iptMsg = previousMessages + currentMessage;

      debugPrint('Message: $iptMsg');

      final CCrequest = ChatCompleteText(
          messages: iptMsg,
          maxToken: 200,
          model: ChatModelFromValue(model: 'gpt-4o'),
          tools: tools,
          toolChoice: "auto");

      final response = await openAI.onChatCompletion(request: CCrequest);

      final responseMsg = response?.choices[0].message;

      if (responseMsg != null) {
        debugPrint('responseMsg: ${responseMsg.toJson()}');
        iptMsg.add(responseMsg.toJson());
      }

      String finalContent = 'placeholder';
      final toolCalls = responseMsg?.toolCalls;
      debugPrint('toolCalls_2: $toolCalls');

      if (toolCalls != null && toolCalls.isNotEmpty) {
        String toolCall_id = toolCalls[0]['id'];
        debugPrint('toolCall_id: $toolCall_id');

        String toolFunctionName = toolCalls[0]['function']['name'];
        debugPrint('toolFunctionName: $toolFunctionName');

        Map<String, dynamic> toolArguments =
            jsonDecode(toolCalls[0]['function']['arguments']);

        if (toolFunctionName == 'add_new_plant') {
          debugPrint('add_new_plant called with arguments: $toolArguments');

          try {
            String species = toolArguments['species'];
            int wateringCycle = toolArguments['wateringCycle'];
            int fertilizationCycle = toolArguments['fertilizationCycle'];
            int pruningCycle = toolArguments['pruningCycle'];

            final results = await addNewPlant(
                species,
                base64Image ?? '',
                wateringCycle,
                fertilizationCycle,
                pruningCycle,
                _plantRepository);

            debugPrint('results: $results');

            iptMsg.add({
              "role": "tool",
              "tool_call_id": toolCall_id,
              "name": toolFunctionName,
              "content": results
            });
          } catch (e) {
            debugPrint('Error in addNewPlant: $e');
          }

          final CCrequestWithFunctionResponse = ChatCompleteText(
            messages: iptMsg,
            model: ChatModelFromValue(model: 'gpt-4o'),
            maxToken: 200,
          );

          try {
            String? message;
            List<Message> msgList = windowMessages;
            msgList.add(Message(text: message ?? '', role: "assistant"));
            notifyListeners();

            final finalResponse = await openAI.onChatCompletion(
                request: CCrequestWithFunctionResponse);
            finalContent = finalResponse?.choices[0].message?.content ?? '';
          } catch (e) {
            debugPrint('Error in finalResponse: $e');
          }
        } else if (toolFunctionName == 'counting_goal') {
          debugPrint('countingGoal called with arguments: $toolArguments');

          try {
            //! goal test
            int cnt_watering = toolArguments['user']['cnt_watering'];

            String lastActionDate = toolArguments['lastActionDate'];
            int wateringCycle = toolArguments['wateringCycle'];
            int fertilizationCycle = toolArguments['fertilizationCycle'];
            int pruningCycle = toolArguments['pruningCycle'];

            final results = counting_goal(lastActionDate, wateringCycle,
                fertilizationCycle, pruningCycle);
            debugPrint('results: $results');

            iptMsg.add({
              "role": "tool",
              "tool_call_id": toolCall_id,
              "name": toolFunctionName,
              "content": results
            });
          } catch (e) {
            debugPrint('Error in calculateNextCareDates: $e');
          }

          final CCrequestWithFunctionResponse = ChatCompleteText(
            messages: iptMsg,
            model: ChatModelFromValue(model: 'gpt-4o'),
            maxToken: 200,
          );

          try {
            String? message;
            List<Message> msgList = windowMessages;
            msgList.add(Message(text: message ?? '', role: "assistant"));
            notifyListeners();

            final finalResponse = await openAI.onChatCompletion(
                request: CCrequestWithFunctionResponse);
            finalContent = finalResponse?.choices[0].message?.content ?? '';
          } catch (e) {
            debugPrint('Error in finalResponse: $e');
          }
        } else if (toolFunctionName == 'find_similar_message') {
          debugPrint(
              'find_and_append_similar_message called with arguments: $toolArguments');

          try {
            String query = toolArguments['query'];

            debugPrint('query: $query');
            final results = await findSimilarMessage(query);

            debugPrint('results: ${results.text}');

            iptMsg.add({
              "role": "tool",
              "tool_call_id": toolCall_id,
              "name": toolFunctionName,
              "content": results.text
            });

            final CCrequestWithFunctionResponse = ChatCompleteText(
              messages: iptMsg,
              model: ChatModelFromValue(model: 'gpt-4o'),
              maxToken: 200,
            );

            final finalResponse = await openAI.onChatCompletion(
                request: CCrequestWithFunctionResponse);
            finalContent = finalResponse?.choices[0].message?.content ?? '';
            //   _messageRepository.addMessage(results) ;
          } catch (e) {
            debugPrint('Error in find_and_append_similar_message: $e');
          }
        } else {
          debugPrint("Error: function $toolFunctionName does not exist");
        }
      } else {
        debugPrint("toolCalls is null or empty: ${responseMsg?.content}");
        finalContent = responseMsg?.content as String;
      }

      if (CCrequestImage != null) {
        final imageResponse =
            await openAI.onChatCompletion(request: CCrequestImage);
        final imageDesMsg = imageResponse?.choices[0].message?.content ?? '';
        debugPrint('Image Des : $imageDesMsg');
        await _messageRepository.addMessage(Message(
            role: message.role,
            text: message.text,
            base64ImageUrl: message.base64ImageUrl,
            imageDescription: imageDesMsg));
      } else {
        await _messageRepository.addMessage(message);
      }
      _messageRepository
          .addMessage(Message(text: finalContent, role: "assistant"));
      return finalContent;
    } catch (e) {
      debugPrint('Error in _chatCompletion: $e');
      return null;
    }
  }
}
