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
import 'package:flutter_app/view_models/all_messages_vm.dart';

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

2. When the user updates that they have watered, fertilized, or pruned a specific plant:
    - Calculate and provide the next watering, fertilization, or pruning date and response.
      - Your response should contain at least one of the following: Next Watering Date, Next Fertilization Date, Next Pruning Date. Depend on the user's input.
      - Your response need not contain other information (species, nickname, watering cycle, fertilization cycle, pruning cycle) unless explicitly asked.
    - Store the last care date that user mentioned in the format 'yyyy-MM-dd'.
      - Your response should contain "last care date" that user mentioned.
    - Do not provide additional information unless explicitly asked.
3. When the user inputs their feelings or thoughts about the plant:
    - Provide a positive and encouraging response to the user's feelings.
    - Include a concise SINGLE bullet point of a fun fact or interesting tidbit about the plant to engage the user.
    - Encourage the user to continue caring for the plant and offer additional tips or advice if needed.
    - Be concise and to the point. Do not provide additional information unless explicitly asked.
4. For any other user inputs:
    - Provide short, clear, and direct answers.
    - Avoid giving additional information unless explicitly asked.

Remember to keep responses brief and focused on the user's query, and a little blend of fun and humor.
""";

  final tools = [
    {
      "type": "function",
      "function": {
        "name": "add_new_plant",
        "description": "Use this function to add a new plant and get related information.",
        "parameters": {
          "type": "object",
          "properties": {
            "species": {"type": "string", "description": "The specific species of the plant."},
            "wateringCycle": {"type": "integer", "description": "The watering cycle of the plant in days."},
            "fertilizationCycle": {"type": "integer", "description": "The fertilization cycle of the plant in days."},
            "pruningCycle": {"type": "integer", "description": "The pruning cycle of the plant in days."}
          },
          "required": ["species", "wateringCycle", "fertilizationCycle", "pruningCycle"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "calculateNextCareDates",
        "description": "Calculates the next care dates for watering, fertilization, and pruning based on the planting date and cycles.",
        "parameters": {
          "type": "object",
          "properties": {
            "lastActionDate": {"type": "string", "description": "The lastAction(water/fertilize/prune) Date of the plant in the format of 'yyyy-MM-dd'."},
            "wateringCycle": {"type": "integer", "description": "The watering cycle of the plant in days."},
            "fertilizationCycle": {"type": "integer", "description": "The fertilization cycle of the plant in days."},
            "pruningCycle": {"type": "integer", "description": "The pruning cycle of the plant in days."}
          },
          "required": ["lastActionDate", "wateringCycle", "fertilizationCycle", "pruningCycle"]
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

  Future<AssistantData> getAssistant() async {
    List<AssistantData> assistantList = await openAI.assistant.v2.list();
    for (var assistant in assistantList) {
      if (assistant.name == "testAssistant") {
        return assistant;
      }
    }
    Assistant assistant = Assistant(name: 'testAssistant', model: Gpt4OModel());
    return openAI.assistant.v2.create(assistant: assistant);
  }

  Future<ThreadResponse> getThread() async {
    threadCreate = await openAI.threads.v2.createThread(request: threadRequest);
    debugPrint('threadCreate: ${threadCreate.id}');
    return threadCreate;
  }

  void updateMessageList(String displayedContent, AllMessagesViewModel viewModel) {
    List<Message> msgList = windowMessages;
    msgList[msgList.length - 1] = Message(text: displayedContent, role: "assistant");
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
    _messageRepository.addMessage(message);
    try {
      dynamic contentMessage;
      bool isImage = false;

      if (message.base64ImageUrl != null) {
        final base64Image = await imageHandler.convertImageToBase64(message.base64ImageUrl!);
        isImage = true;

        contentMessage = [
          {"type": "text", "text": message.text},
          {"type": "image_url", "image_url": {"url": base64Image}}
        ];
      } else {
        contentMessage = [{"type": "text", "text": message.text}];
      }

      if (isImage) {
        final iptMsg = [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": contentMessage}
        ];

        final CCrequest = ChatCompleteText(
          messages: iptMsg,
          maxToken: 200,
          model: ChatModelFromValue(model: 'gpt-4o'),
          tools: tools,
          toolChoice: 'required'
        );

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

          Map<String, dynamic> toolArguments = jsonDecode(toolCalls[0]['function']['arguments']);

          if (toolFunctionName == 'add_new_plant') {
            debugPrint('add_new_plant called with arguments: $toolArguments');

            try {
              String species = toolArguments['species'];
              int wateringCycle = toolArguments['wateringCycle'];
              int fertilizationCycle = toolArguments['fertilizationCycle'];
              int pruningCycle = toolArguments['pruningCycle'];

              final results = await addNewPlant(species, wateringCycle, fertilizationCycle, pruningCycle);

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

              final finalResponse = await openAI.onChatCompletion(request: CCrequestWithFunctionResponse);
              finalContent = finalResponse?.choices[0].message?.content ?? '';
            } catch (e) {
              debugPrint('Error in finalResponse: $e');
            }
          } else if (toolFunctionName == 'calculateNextCareDates') {
            debugPrint('calculateNextCareDates called with arguments: $toolArguments');

            try {
              String lastActionDate = toolArguments['lastActionDate'];
              int wateringCycle = toolArguments['wateringCycle'];
              int fertilizationCycle = toolArguments['fertilizationCycle'];
              int pruningCycle = toolArguments['pruningCycle'];

              final results = calculateNextCareDatesTool(lastActionDate, wateringCycle, fertilizationCycle, pruningCycle);
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

              final finalResponse = await openAI.onChatCompletion(request: CCrequestWithFunctionResponse);
              finalContent = finalResponse?.choices[0].message?.content ?? '';
            } catch (e) {
              debugPrint('Error in finalResponse: $e');
            }
          } else {
            debugPrint("Error: function $toolFunctionName does not exist");
          }
        } else {
          debugPrint("toolCalls is null or empty: ${responseMsg?.content}");
        }

        CreateMessage MSGrequest = CreateMessage(role: 'user', content: finalContent);

        CreateMessageV2Response MSGresponse = await openAI.threads.v2.messages.createMessage(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          request: MSGrequest,
        );

        CreateRun request = CreateRun(
          assistantId: 'asst_K9Irkl24BOJpXnDjvjbfX2aq',
          model: 'gpt-4o',
          instructions: "remember the related information for the plant, you do not have to respond upon receive this message",
        );

        final runResponse = await openAI.threads.v2.runs.createRun(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          request: request,
        );

        final runid = runResponse.id;

        CreateRunResponse mRun = await openAI.threads.v2.runs.retrieveRun(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          runId: runid,
        );

        while (mRun.status != 'completed') {
          await Future.delayed(Duration(seconds: 3));
          mRun = await openAI.threads.v2.runs.retrieveRun(
            threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
            runId: runid,
          );
        }
        debugPrint('Retrieved run details: ${mRun.status}');
        _messageRepository.addMessage(Message(text: finalContent, role: "assistant"));
        return finalContent;
      } else {
        debugPrint('Creating message request...');
        debugPrint('$contentMessage ${contentMessage.runtimeType}');
        
        CreateMessage MSGrequest = CreateMessage(role: 'user', content: contentMessage[0]["text"]);
        debugPrint('CreateMessage request created: $MSGrequest');

        CreateMessageV2Response MSGresponse = await openAI.threads.v2.messages.createMessage(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          request: MSGrequest,
        );

        debugPrint('Received CreateMessage response: $MSGresponse');

        CreateRun request = CreateRun(
          assistantId: 'asst_K9Irkl24BOJpXnDjvjbfX2aq',
          model: 'gpt-4o',
          instructions: "test prompt",
        );

        debugPrint('CreateRun request created: $request');

        final runResponse = await openAI.threads.v2.runs.createRun(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          request: request,
        );
        debugPrint('Received CreateRun response: $runResponse');

        final runid = runResponse.id;
        debugPrint('Run ID: $runid');

        CreateRunResponse mRun = await openAI.threads.v2.runs.retrieveRun(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          runId: runid,
        );

        while (mRun.status != 'completed') {
          await Future.delayed(Duration(seconds: 3));
          mRun = await openAI.threads.v2.runs.retrieveRun(
            threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
            runId: runid,
          );
        }
        debugPrint('Retrieved run details: ${mRun.status}');

        ListRun mRunSteps = await openAI.threads.v2.runs.listRunSteps(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          runId: runid,
        );

        CreateMessageV2Response mMessage;
        String? msgID = mRunSteps.data[0].stepDetails?.messageCreation.messageId;
        String? messageData;

        if (msgID != null) {
          debugPrint('msgID: $msgID');
          mMessage = await openAI.threads.v2.messages.retrieveMessage(
            threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
            messageId: msgID,
          );

          debugPrint('mMessage: $mMessage');
          messageData = mMessage.content[0].text.value;
        }

        String? message;
        List<Message> msgList = windowMessages;
        msgList.add(Message(text: message ?? '', role: "assistant"));
        notifyListeners();
        String fullContent = messageData ?? '';
        //await displayContentWithStreamingEffect(fullContent, viewModel);
        _messageRepository.addMessage(Message(text: fullContent, role: "assistant"));
        return messageData;
      }
    } catch (e) {
      debugPrint('Error in _chatCompletion: $e');
      return null;
    }
  }
}
