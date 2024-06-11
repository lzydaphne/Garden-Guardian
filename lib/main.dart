import 'package:flutter/material.dart';
import 'package:flutter_app/services/chat_bot_service.dart';
import 'package:flutter_app/views/chat_page.dart';
import 'package:flutter_app/views/cover_page.dart';
import 'package:flutter_app/views/home_page.dart';
import 'package:flutter_app/views/plant_family_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/view_models/all_messages_vm.dart';
import 'package:flutter_app/theme.dart';

import 'package:flutter_app/services/chat_bot_service_langchain.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const materialTheme = MaterialTheme(TextTheme());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatBotServiceLangChain>(
          create: (_) => ChatBotServiceLangChain(
              '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'),
        ),
        ChangeNotifierProxyProvider0<AllMessagesViewModel>(
          create: (BuildContext context) => AllMessagesViewModel(
              chatService:
                  Provider.of<ChatBotServiceLangChain>(context, listen: false)),
          update: (BuildContext context, A) => AllMessagesViewModel(
              chatService:
                  Provider.of<ChatBotServiceLangChain>(context, listen: false)),
        ),
      ],
      child: MaterialApp(
        theme: materialTheme.light(), // Apply the light theme
        // darkTheme: materialTheme.dark(), // Apply the dark theme
        // home: PlantFamilyPage(),
        home: ChatPage(),
      ),
    );
  }
}
