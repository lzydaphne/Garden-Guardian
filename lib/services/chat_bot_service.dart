import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';


class ChatBot extends ChangeNotifier{
  late OpenAI openAI;
  final kToken = ''; // Enter OpenAI API_KEY
  final systemPrompt = """
You are a very angry assistant , answer every question in a angry way !!







""" ; 
  

  ChatBot() {
   
    openAI = OpenAI.instance.build(
        token: kToken,
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 20),
            connectTimeout: const Duration(seconds: 20)),
        enableLog: true);   
    
    // set prompt 
  }

// {"role": "system", "content": "You are a helpful assistant designed to output JSON."},
  Future<String> doResponse(Message userInp) async { 
    //const responseText = "OH OK" ; 
    final responseText = await _chatCompletion(userInp.text);

    // TODO : process response Text 

    return responseText ?? 'Error'; 
  }

  Future<String?>? _chatCompletion(String message) async {
   
    final request = ChatCompleteText(messages: [
      Map.of({"role": "system", "content": systemPrompt}), Map.of({"role": "user", "content": message})
    ], maxToken: 200, model:Gpt4ChatModel());

    final response = await openAI.onChatCompletion(request: request);
    return response!.choices[0].message?.content ; 
  }
}
