import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ChatBot extends ChangeNotifier {
  late OpenAI openAI;
  final kToken = ''; // Enter OpenAI API_KEY
  final systemPrompt = """
You are a very angry assistant, answer every question in an angry way!!
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
      if (message.imageUrl != null) {
        
        final base64Image = await _convertImageToBase64(message.imageUrl!);
      
        contentMessage = [
          {"type": "text", "text": message.text},
          {"type": "image_url", "image_url":{"url":base64Image}},
        ];
      } else {
        contentMessage = message.text;
      }

      final request = ChatCompleteText(
        messages: [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": contentMessage},
        ],
        maxToken: 200,
        model: ChatModelFromValue(model: 'gpt-4o'),
      );

      final response = await openAI.onChatCompletion(request: request);
      return response?.choices[0].message?.content;
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
      final mimeType = _getMimeType(imagePath);
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

  String _getMimeType(String imagePath) {
      return 'image/jpeg';
  }
}
