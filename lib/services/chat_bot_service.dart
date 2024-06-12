import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_app/services/tool.dart';

/**
 * Assistant ID: asst_2KEXqEXcWF9CAn7iL9aDfewC
* thread ID: thread_lKTJ4mwXgWcKsLtZgCHeXWy1
 */

class ChatBot extends ChangeNotifier {
  late OpenAI openAI;
  late ThreadRequest threadRequest;
  late ThreadResponse threadCreate;

  // late AssistantsV2 assistantsV2;
  final kToken =
      'sk-proj-bofrvC0NKYWbFXzBvFdJT3BlbkFJc95fuqr5951O8qR3ZZYh'; // Enter OpenAI API_KEY
  final systemPrompt = """
You are a personal plant assistant, called PlantPal!
PlantPal is an advanced AI-powered assistant designed to provide comprehensive information and assistance related to plants. Whether you're a seasoned gardener, a beginner plant parent, or simply curious about the world of flora, PlantPal is here to help. Below are the detailed functionalities and capabilities of PlantPal:
you output must include with plain text, no markdown and you may extend your response with any additional information:
- specific species of the plant 
- planting date (today)
- watering cycle, fertilization cycle, pruning cycle of this plant, express it in number of days, if no, then say "not typically required"
you have the following features
1. Plant Identification:
PlantPal utilizes state-of-the-art image recognition technology to accurately identify plants from uploaded photos. Users can upload images of plants they encounter in their surroundings, whether in their garden, on a hike, or at a friend's house.
Upon receiving an image, PlantPal will analyze it using deep learning algorithms trained on vast datasets of plant images. The system will then compare features such as leaf shape, flower morphology, and overall structure to a vast database of plant species.
PlantPal will provide users with the most likely identification of the plant in the image, including its common name, scientific name (genus and species), and relevant information such as preferred growing conditions, care tips, and potential uses (e.g., ornamental, culinary, medicinal).
2. Plant Care Guidance:
Users can ask PlantPal for personalized care guidance for specific plants they own or are interested in acquiring. This includes information on watering frequency, sunlight requirements, soil type, temperature preferences, pruning techniques, and pest control measures.
PlantPal takes into account the geographic location of the user to provide tailored recommendations based on local climate conditions, ensuring optimal plant care advice.
3. Plant Information Database:
PlantPal maintains an extensive database of plant species, including both common and rare varieties from around the world. Users can search this database by plant name, characteristics, or growing conditions to access detailed information on a wide range of plants.
Each plant entry in the database includes botanical descriptions, native habitats, cultivation history, interesting facts, and any cultural or symbolic significance associated with the plant.
4. Interactive Plant Q&A:
PlantPal offers a conversational interface where users can ask questions about plants in natural language. Whether it's inquiries about specific plant species, gardening techniques, plant diseases, or troubleshooting plant problems, PlantPal is equipped to provide informative and helpful responses.
The AI model underlying PlantPal is trained on vast corpora of plant-related texts, including botanical literature, gardening guides, academic papers, and online forums, ensuring a rich and diverse knowledge base.
""";

  ChatBot() {
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
    print('threadCreate: ${'thread_lKTJ4mwXgWcKsLtZgCHeXWy1'}');
    return threadCreate;
  }

  Future<String> doResponse(Message userInp) async {
    try {
      final responseText = await _chatCompletion(userInp);
      return responseText ?? 'Error123';
    } catch (e) {
      print('Error in doResponse: $e');
      return 'Error';
    }
  }

  Future<String?> _chatCompletion(Message message) async {
    // try {
    dynamic contentMessage;
    bool isImage = false;
    if (message.imageUrl != null) {
      final base64Image = await _convertImageToBase64(message.imageUrl!);
      isImage = true;
      contentMessage = [
        // {"type": "text", "text": message.text},
        {"type": "text", "text": 'placeholder for image message'},
        {
          "type": "image_url",
          "image_url": {"url": base64Image}
        },
      ];
    } else {
      contentMessage = message.text;
    }
    // function implement reference:https://cookbook.openai.com/examples/how_to_call_functions_with_chat_models
    if (isImage) {
      final iptMsg = [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": contentMessage},
      ];
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
              ],
            },
          }
        }
      ];
      final CCrequest = ChatCompleteText(
        messages: iptMsg,
        maxToken: 200,
        model: ChatModelFromValue(model: 'gpt-4o'),
        tools: tools,
        toolChoice:
            'auto', //! we can force it to execute the function by function name
      );

      final response = await openAI.onChatCompletion(request: CCrequest);
      String? chatContent = response?.choices[0].message?.content;
      //! check if the function works!
      // print('toolCalls_1: ${response?.choices[0].message}');
      // return chatContent;

      final responseMsg = response?.choices[0].message;

      // Append the toolCalls to iptMsg if toolCalls is not null
      if (responseMsg != null) {
        print('responseMsg: ${responseMsg.toJson()}');
        iptMsg.add(responseMsg.toJson());
      }

      // Step 3: Check if the response includes a tool call
      String finalContent = 'placeholder';
      final toolCalls = responseMsg?.toolCalls;
      print('toolCalls_2: $toolCalls');
      if (toolCalls != null && toolCalls.isNotEmpty) {
        // final toolCall = toolCalls[0];
        String toolCall_id = toolCalls[0]['id'];
        print('toolCall_id: $toolCall_id');
        String toolFunctionName = toolCalls[0]['function']['name'];
        print('toolFunctionName: $toolFunctionName');
        Map<String, dynamic> toolArguments =
            jsonDecode(toolCalls[0]['function']['arguments']);
        if (toolFunctionName == 'add_new_plant') {
          print('add_new_plant called with arguments: $toolArguments');
          try {
            //*example
            // final results = addNewPlant("Ficus lyrata", 7, 14, 30);
            String species = toolArguments['species'];
            int wateringCycle = toolArguments['wateringCycle'];
            int fertilizationCycle = toolArguments['fertilizationCycle'];
            int pruningCycle = toolArguments['pruningCycle'];
            final results = await addNewPlant(
                species, wateringCycle, fertilizationCycle, pruningCycle);
            print('results: $results');
            // Append the results to the messages list
            iptMsg.add({
              "role": "tool",
              "tool_call_id": toolCall_id,
              "name": toolFunctionName,
              "content": results
            });
          } catch (e) {
            print('Error in addNewPlant: $e');
          }

          // Step 5: Invoke the chat completions API with the function response appended to the messages list
          final CCrequestWithFunctionResponse = ChatCompleteText(
            messages: iptMsg,
            model: ChatModelFromValue(model: 'gpt-4o'),
            maxToken: 200,
          );

          //try and error
          try {
            final finalResponse = await openAI.onChatCompletion(
                request: CCrequestWithFunctionResponse);
            print(finalResponse?.choices[0].message?.content);
            finalContent = finalResponse?.choices[0].message?.content ?? '';
          } catch (e) {
            print('Error in finalResponse: $e');
          }
        } else {
          print("Error: function $toolFunctionName does not exist");
        }
      } else {
        // Model did not identify a function to call, result can be returned to the user
        print("toolCalls is null or empty: ${responseMsg?.content}");
      }
      // return finalContent;
      //=================================================================
      CreateMessage MSGrequest =
          CreateMessage(role: 'assistant', content: finalContent);

      CreateMessageV2Response MSGresponse =
          await openAI.threads.v2.messages.createMessage(
        threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
        request: MSGrequest,
      );

      CreateRun request = CreateRun(
        assistantId: 'asst_2KEXqEXcWF9CAn7iL9aDfewC',
        model: 'gpt-4o',
        // instructions: "",
        instructions: "remember the related information for the plant",
      );

      final runResponse = await openAI.threads.v2.runs.createRun(
        threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
        request: request,
      );

      final runid = runResponse.id;

      CreateRunResponse mRun = await openAI.threads.v2.runs.retrieveRun(
        threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
        runId: runid,
      );
// what is my latest added plant?
      while (mRun.status != 'completed') {
        await Future.delayed(Duration(seconds: 3));
        mRun = await openAI.threads.v2.runs.retrieveRun(
          threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
          runId: runid,
        );
      }
      print('Retrieved run details: ${mRun.status}');

      return finalContent;
    } else {
      // Debugging: Starting CreateMessage request
      print('Creating message request...');
      CreateMessage MSGrequest = CreateMessage(
        role: 'user',
        content: contentMessage,
      );

      print('CreateMessage request created: $MSGrequest');

      CreateMessageV2Response MSGresponse =
          await openAI.threads.v2.messages.createMessage(
        threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
        request: MSGrequest,
      );

      // Debugging: Received response for CreateMessage
      print('Received CreateMessage response: $MSGresponse');

      // Debugging: Starting CreateRun request
      print('Creating run request...');
      // AssistantData assistantInfo = await getAssistant();
      // print('Assistant ID: ${assistantInfo.id}');
      CreateRun request = CreateRun(
        assistantId: 'asst_2KEXqEXcWF9CAn7iL9aDfewC',
        model: 'gpt-4o',
        instructions: "test prompt",
        // instructions: systemPrompt,
      );
      // Debugging: CreateRun request created
      print('CreateRun request created: $request');

      // Debugging: Sending CreateRun request to API
      final runResponse = await openAI.threads.v2.runs.createRun(
        threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
        request: request,
      );
      // Debugging: Received response for CreateRun
      print('Received CreateRun response: $runResponse');

      final runid = runResponse.id;
      // final msg = runResponse.stepDetails?.messageCreation.messageId;
      // Debugging: Run ID retrieved
      print('Run ID: $runid');

      CreateRunResponse mRun = await openAI.threads.v2.runs.retrieveRun(
        threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
        runId: runid,
      );

      while (mRun.status != 'completed') {
        await Future.delayed(Duration(seconds: 3));
        mRun = await openAI.threads.v2.runs.retrieveRun(
          threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
          runId: runid,
        );
      }
      print('Retrieved run details: ${mRun.status}');

      // ListRun mRunlist = await openAI.threads.v2.runs.listRuns(
      //   threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
      // );
      // print('List of runs: $mRunlist');

      ListRun mRunSteps = await openAI.threads.v2.runs.listRunSteps(
        threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
        runId: runid,
      );
      // print('List of run steps: $mRunSteps');
      // print(mRunSteps.data.length);
      // mRunSteps.data.forEach((item) {
      //   print('mRunlist: ${item.status}');
      //   print('mRunlist: ${item.object}');
      //   print('mRunlist: ${item.id}');
      //   print('mRunlist: ${item.stepDetails?.messageCreation.messageId}');
      // });

      CreateMessageV2Response mMessage;
      String? msgID = mRunSteps.data[0].stepDetails?.messageCreation.messageId;
      String? messageData;

      if (msgID != null) {
        print('msgID: $msgID');
        mMessage = await openAI.threads.v2.messages.retrieveMessage(
          threadId: 'thread_lKTJ4mwXgWcKsLtZgCHeXWy1',
          messageId: msgID,
        );

        print('mMessage: $mMessage');
        print(mMessage.content.length);
        messageData = mMessage.content[0].text.value;
      }
      return messageData;
    }
    // }
    // catch (e) {
    //   print('Error in _chatCompletion: $e');
    //   return null;
    // }
  }

  Future<String> _convertImageToBase64(String imagePath) async {
    try {
      print(imagePath);
      final bytes = await readImageAsBytes(imagePath);
      if (bytes == null) {
        throw Exception("Failed to load image");
      }
      final base64String = base64Encode(bytes);
      final mimeType = lookupMimeType(imagePath, headerBytes: bytes);
      print(mimeType);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      print('Error in _convertImageToBase64: $e');
      return 'Error';
    }
  }

  Future<Uint8List?> readImageAsBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }
}
