import 'package:flutter/material.dart';
import 'package:flutter_app/views/message_list.dart';
import 'package:flutter_app/views/new_message_bar.dart';
import 'package:flutter_app/views/user_info.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          IconButton(
            onPressed: () {
              // Information button logic
            },
            icon: Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          UserInfo(),
          Expanded(
            child: MessageList(),
          ),
          // LeftIcons
          NewMessageBar(),
        ],
      ),
    );
  }
}
