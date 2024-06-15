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

  // TODO : compress image for file space
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

  String kToken =
      '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'; // use lzy's token
  // final String kToken =
  //     'sk-proj-bofrvC0NKYWbFXzBvFdJT3BlbkFJc95fuqr5951O8qR3ZZYh';
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
                    "description":
                        "The fertilization cycle of the plant in days."
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
                ],
              },
            }
          },
          {
            "type": "function",
            "function": {
              "name": "calculateNextCareDates",
              "description":
                  "Calculates the next care dates for watering, fertilization, and pruning based on the planting date and cycles.",
              "parameters": {
                "type": "object",
                "properties": {
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
                    "description":
                        "The fertilization cycle of the plant in days."
                  },
                  "pruningCycle": {
                    "type": "integer",
                    "description": "The pruning cycle of the plant in days."
                  }
                },
                "required": [
                  "lastActionDate",
                  "wateringCycle",
                  "fertilizationCycle",
                  "pruningCycle"
                ],
              },
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
    threadRequest = ThreadRequest();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  // get or create an assistant
  Future<AssistantData> getAssistant() async {
    List<AssistantData> assistantList = await openAI.assistant.v2.list();
    for (var assistant in assistantList) {
      //get gpt-4o model assistant
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

  // Future<void> displayContentWithStreamingEffect(
  //     String fullContent, AllMessagesViewModel viewModel) async {
  //   String displayedContent = "";
  //   const int chunkSize = 10; // Adjust the chunk size as needed
  //   const int delayDuration = 100; // Delay duration in milliseconds

  //   // Split the full content into chunks and display it incrementally
  //   for (int i = 0; i < fullContent.length; i += chunkSize) {
  //     // Extract a chunk of the content
  //     String chunk = fullContent.substring(
  //         i,
  //         i + chunkSize > fullContent.length
  //             ? fullContent.length
  //             : i + chunkSize);

  //     // Concatenate the chunk to the displayed content
  //     displayedContent += chunk;

  //     // Update the last message in the message list with the current displayed content
  //     updateMessageList(displayedContent, viewModel);

  //     // Introduce a delay to create the streaming effect
  //     await Future.delayed(Duration(milliseconds: delayDuration));
  //   }
  // }

  // void updateMessageList(
  //     String displayedContent, AllMessagesViewModel viewModel) {
  //   // Update the last message in the message list with the current displayed content
  //   List<Message> msgList = viewModel.messages;
  //   msgList[msgList.length - 1] = Message(text: displayedContent, role: "BOT");

  //   // Notify listeners to update the UI
  //   viewModel.notifyListeners();
  // }

  Future<String> doResponse(
      Message userInp) async {
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


      if (message.base64ImageUrl != null) {
        final base64Image = await imageHandler.convertImageToBase64(message.base64ImageUrl!);
        isImage = true;

        debugPrint('nessage text: ${message.text}');

        contentMessage = [
          {"type": "text", "text": message.text},
          // {"type": "text", "text": 'placeholder'},
          {
            "type": "image_url",
            "image_url": {"url": base64Image}
          },
        ];
      } else {
        contentMessage = [{"type": "text", "text": message.text}];
      }
      // function implement reference:https://cookbook.openai.com/examples/how_to_call_functions_with_chat_models
      if (isImage) {
        final iptMsg = [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": contentMessage},
        ];
        
        final CCrequest = ChatCompleteText(
          messages: iptMsg,
          maxToken: 200,
          model: ChatModelFromValue(model: 'gpt-4o'),
          tools: tools,
          toolChoice:
              'required', //! we can force it to execute the function by function name
          // toolChoice: {
          //   "type": "function",
          //   "function": {"name": "add_new_plant"}
          // },
        );

        final response = await openAI.onChatCompletion(request: CCrequest);
       // String? chatContent = response?.choices[0].message?.content;
        //! check if the function works!
        // debugPrint('toolCalls_1: ${response?.choices[0].message}');
        // return chatContent;

        final responseMsg = response?.choices[0].message;

        // Append the toolCalls to iptMsg if toolCalls is not null
        if (responseMsg != null) {
          debugPrint('responseMsg: ${responseMsg.toJson()}');
          iptMsg.add(responseMsg.toJson());
        }

        // Step 3: Check if the response includes a tool call
        String finalContent = 'placeholder';
        final toolCalls = responseMsg?.toolCalls;
        debugPrint('toolCalls_2: $toolCalls');


        if (toolCalls != null && toolCalls.isNotEmpty) {
          // final toolCall = toolCalls[0];
          String toolCall_id = toolCalls[0]['id'];
          debugPrint('toolCall_id: $toolCall_id');

          String toolFunctionName = toolCalls[0]['function']['name'];
          debugPrint('toolFunctionName: $toolFunctionName');

          Map<String, dynamic> toolArguments = jsonDecode(toolCalls[0]['function']['arguments']);

          if (toolFunctionName == 'add_new_plant') {
            debugPrint('add_new_plant called with arguments: $toolArguments');
            
            try {
              //*example
              // final results = addNewPlant("Ficus lyrata", 7, 14, 30);
              String species = toolArguments['species'];
              int wateringCycle = toolArguments['wateringCycle'];
              int fertilizationCycle = toolArguments['fertilizationCycle'];
              int pruningCycle = toolArguments['pruningCycle'];

              
              final results = await addNewPlant(species, wateringCycle, fertilizationCycle, pruningCycle);

              debugPrint('results: $results');
              // Append the results to the messages list
              
              iptMsg.add({
                "role": "tool",
                "tool_call_id": toolCall_id,
                "name": toolFunctionName,
                "content": results
              });
            } catch (e) {
              debugPrint('Error in addNewPlant: $e');
            }

            // Step 5: Invoke the chat completions API with the function response appended to the messages list
            final CCrequestWithFunctionResponse = ChatCompleteText(
              messages: iptMsg,
              model: ChatModelFromValue(model: 'gpt-4o'),
              maxToken: 200,
            );

            //*+++++++++ streaming use onChatCompletionSSE, it works but too fast to see the streaming effect, so using brute force way to see the streaming effect
            /*
            openAI
                .onChatCompletionSSE(request: CCrequestWithFunctionResponse)
                .transform(StreamTransformer.fromHandlers(
                    handleError: handleStreamError))
                .listen((it) {
              // debugPrint('streamResponse.id: ${it.id}');
              // debugPrint('streamResponse.object: ${it.object}');
              // debugPrint('streamResponse.content: ${it.choices[0].message.content}');
              // Message? msg;
              // List<Message> msgList = viewModel.getMessages();
              // msgList.removeWhere((element) {
              //   if (element.id == '${it.id}') {
              //     msg = element;
              //     debugPrint('element: $element');
              //     return true;
              //   }
              //   return false;
              // });

              ///+= message
              message =
                  '${message ?? ""}${it.choices[0].message?.content ?? ""}';
              debugPrint("stream msg: $message");
              msgList[msgList.length - 1] =
                  Message(text: message ?? '', userName: "BOT");
              viewModel.notifyListeners();
              // Update the message list in the viewModel
              // viewModel.setMessages(msgList);
            });*/

            try {
              //preparetion for streaming response
              // String? message;
              // List<Message> msgList = windowMessages;
              // msgList.add(Message(text: message ?? '', role: "BOT"));
              // notifyListeners();
              //
              final finalResponse = await openAI.onChatCompletion(
                  request: CCrequestWithFunctionResponse);
              // String fullContent =
              //     finalResponse?.choices[0].message?.content ?? '';
         //     await displayContentWithStreamingEffect(fullContent, viewModel);
              finalContent = finalResponse?.choices[0].message?.content ?? '';
//api done              
            } catch (e) {
              debugPrint('Error in finalResponse: $e');
            }
            //! calculateNextCareDatesTool
          } else if (toolFunctionName == 'calculateNextCareDates') {
            debugPrint( 'calculateNextCareDates called with arguments: $toolArguments');

            try {

              String lastActionDate = toolArguments['lastActionDate'];
              int wateringCycle = toolArguments['wateringCycle'];
              int fertilizationCycle = toolArguments['fertilizationCycle'];
              int pruningCycle = toolArguments['pruningCycle'];

              final results = calculateNextCareDatesTool(lastActionDate, wateringCycle, fertilizationCycle, pruningCycle);
              debugPrint('results: $results');

              // Append the results to the messages list
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
              //preparetion for streaming response
              // String? message;
              // List<Message> msgList = windowMessages;
              // msgList.add(Message(text: message ?? '', role: "BOT"));
              // notifyListeners();
              //
              final finalResponse = await openAI.onChatCompletion(
                  request: CCrequestWithFunctionResponse);
              // String fullContent =
              //     finalResponse?.choices[0].message?.content ?? '';
         //     await displayContentWithStreamingEffect(fullContent, viewModel);
              finalContent = finalResponse?.choices[0].message?.content ?? '';
//api done
            } catch (e) {
              debugPrint('Error in finalResponse: $e');
            }
          } else {
            debugPrint("Error: function $toolFunctionName does not exist");
          }
        } else {
          // Model did not identify a function to call, result can be returned to the user
          debugPrint("toolCalls is null or empty: ${responseMsg?.content}");
        }
        // return finalContent;
        //=================================================================
        //test: what is my latest added plant?
        CreateMessage MSGrequest = CreateMessage(role: 'user', content: finalContent);

        CreateMessageV2Response MSGresponse = await openAI.threads.v2.messages.createMessage(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          request: MSGrequest,
        );

        CreateRun request = CreateRun(
          assistantId: 'asst_K9Irkl24BOJpXnDjvjbfX2aq',
          model: 'gpt-4o',
          // instructions: "",
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

        return finalContent;
      } else {
        // Debugging: Starting CreateMessage request
        debugPrint('Creating message request...');
        debugPrint('$contentMessage ${contentMessage.runtimeType}');
        //error , need to fix 
        CreateMessage MSGrequest = CreateMessage(
          role: 'user',
          content: contentMessage[0]["text"],
        );
        debugPrint('CreateMessage request created: $MSGrequest');
        //build new assistant and thread
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        // AssistantData assistantInfo = await getAssistant();
        // debugPrint('Assistant ID: ${assistantInfo.id}');
        // await getThread();
        // return 'Error';

        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        CreateMessageV2Response MSGresponse =
            await openAI.threads.v2.messages.createMessage(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          request: MSGrequest,
        );

        debugPrint('Received CreateMessage response: $MSGresponse');

        debugPrint('Creating run request...');

        CreateRun request = CreateRun(
          assistantId: 'asst_K9Irkl24BOJpXnDjvjbfX2aq',
          model: 'gpt-4o',
          instructions: "test prompt",
          // instructions: systemPrompt,
        );
        // Debugging: CreateRun request created
        debugPrint('CreateRun request created: $request');

        // Debugging: Sending CreateRun request to API
        final runResponse = await openAI.threads.v2.runs.createRun(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          request: request,
        );
        // Debugging: Received response for CreateRun
        debugPrint('Received CreateRun response: $runResponse');

        final runid = runResponse.id;
        // final msg = runResponse.stepDetails?.messageCreation.messageId;
        // Debugging: Run ID retrieved
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

        // ListRun mRunlist = await openAI.threads.v2.runs.listRuns(
        //   threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
        // );
        // debugPrint('List of runs: $mRunlist');

        ListRun mRunSteps = await openAI.threads.v2.runs.listRunSteps(
          threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
          runId: runid,
        );
        // debugPrint('List of run steps: $mRunSteps');
        // debugPrint(mRunSteps.data.length);
        // mRunSteps.data.forEach((item) {
        //   debugPrint('mRunlist: ${item.status}');
        //   debugPrint('mRunlist: ${item.object}');
        //   debugPrint('mRunlist: ${item.id}');
        //   debugPrint('mRunlist: ${item.stepDetails?.messageCreation.messageId}');
        // });

        CreateMessageV2Response mMessage;
        String? msgID =
            mRunSteps.data[0].stepDetails?.messageCreation.messageId;
        String? messageData;

        if (msgID != null) {
          debugPrint('msgID: $msgID');
          mMessage = await openAI.threads.v2.messages.retrieveMessage(
            threadId: 'thread_jfsm4Y9BERuGZXcSySsLSEbV',
            messageId: msgID,
          );

          debugPrint('mMessage: $mMessage');
          debugPrint(mMessage.content.length as String);
          messageData = mMessage.content[0].text.value;
        }

        //! streaming for text response for text input
        //preparetion for streaming response
        // String? message;
        // List<Message> msgList = windowMessages;
        // msgList.add(Message(text: message ?? '', role: "BOT"));
        // notifyListeners();
        // String fullContent = messageData ?? '';
       // await displayContentWithStreamingEffect(fullContent, viewModel);

        return messageData;
      }
    } catch (e) {
      debugPrint('Error in _chatCompletion: $e');
      return null;
    }
  }
}
