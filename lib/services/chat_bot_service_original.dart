import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
/** 
 * 
class ChatBot extends ChangeNotifier {
  late OpenAI openAI;
  final kToken =
      'sk-proj-Ts7SQosv2dR9aM1nTNzHT3BlbkFJVZRJRtP0tVMD4n3qyLeE'; // Enter OpenAI API_KEY
  // final kToken ='sk-proj-bofrvC0NKYWbFXzBvFdJT3BlbkFJc95fuqr5951O8qR3ZZYh'; // Enter OpenAI API_KEY
  String systemPrompt = 
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


  ChatBot() {
    openAI = OpenAI.instance.build(
      token: kToken,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 20),
      ),
      enableLog: true,
    );
  }

  Future<String> doResponse(Message userInp) async {
    try {
      final responseText = await _chatCompletion(userInp);
      return responseText ?? 'Error';
    } catch (e) {
      print('Error in doResponse: $e');
      return 'Error';
    }
  }

  Future<String?> _chatCompletion(Message message) async {
    try {
      dynamic contentMessage;
      if (message.base64ImageUrl != null) {
        final base64Image =
            await _convertImageToBase64(message.base64ImageUrl!);

        contentMessage = [
          {"type": "text", "text": message.text},
          {
            "type": "image_url",
            "image_url": {"url": base64Image}
          },
        ];
      } else {
        contentMessage = message.text;
      }

      // final request = ChatCompleteText(
      //   messages: [
      //     {"role": "system", "content": systemPrompt},
      //     {"role": "user", "content": contentMessage},
      //   ],
      //   maxToken: 200,
      //   model: ChatModelFromValue(model: 'gpt-4o'),
      // );

      CreateMessage MSGrequest = CreateMessage(
        role: 'user',
        content: contentMessage,
      );
      MessageData MSGresponse = await openAI.threads.messages.createMessage(
        threadId: 'thread_iJpSkcxUGIKdM7vyYq13dxBL',
        request: MSGrequest,
      );

      CreateRun request = CreateRun(
        assistantId: 'asst_6VOoLqMJaVnx3d18lcTFOgq9',
        model: 'gpt-4-turbo-preview',
        // instructions: systemPrompt,
      );
      final runResponse = await openAI.threads.runs.createRun(
          threadId: 'thread_iJpSkcxUGIKdM7vyYq13dxBL', request: request);

      final runid = runResponse.id;
      CreateRunResponse mRun = await openAI.threads.runs.retrieveRun(
        threadId: 'thread_iJpSkcxUGIKdM7vyYq13dxBL',
        runId: runid,
      );
      ListRun mRunlist = await openAI.threads.runs
          .listRuns(threadId: 'thread_iJpSkcxUGIKdM7vyYq13dxBL');
      ListRun mRunSteps = await openAI.threads.runs.listRunSteps(
        threadId: 'thread_iJpSkcxUGIKdM7vyYq13dxBL',
        runId: runid,
      );
      print(mRunSteps.data.length);
      mRunSteps.data.forEach((item) {
        print('mRunlist: ${item.status}');
        print('mRunlist: ${item.object}');
        print('mRunlist: ${item.id}');
        print('mRunlist: ${item.stepDetails?.messageCreation.messageId}');
      });

      // Assuming CreateRunResponse has fields like id, status, assistantId, etc.
      // print('CreateRunResponse:');
      // print('ID: ${mRun.id}');
      // print('Status: ${mRun.status}');
      // print('Assistant ID: ${mRun.assistantId}');
      // print('Thread ID: ${mRun.threadId}');
      // print('Model: ${mRun.model}');
      // print('Started At: ${mRun.startedAt}');
      // print('stepDetails: ${mRun.stepDetails}');

      MessageData mMessage;
      String? msgID = mRunSteps.data[0].stepDetails?.messageCreation.messageId;
      String? messageData;

      // print('msgID1: $msgID');
      if (msgID != null) {
        print('msgID: $msgID');
        mMessage = await openAI.threads.messages.retrieveMessage(
          threadId: 'thread_iJpSkcxUGIKdM7vyYq13dxBL',
          messageId: msgID,
        );
        print('mMessage: $mMessage');
        messageData = mMessage.content[0].text?.value;
      }

      return messageData;

      // final response = await openAI.onChatCompletion(request: request);
      // return response?.choices[0].message?.content;
    } catch (e) {
      print('Error in _chatCompletion: $e');
      return null;
    }
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
*/