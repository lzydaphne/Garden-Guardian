import 'package:flutter/material.dart';
// import 'package:flutter_app/services/authentication.dart';
//import 'package:flutter_app/services/push_messaging.dart';
//import 'package:flutter_app/view_models/me_vm.dart';
import 'package:flutter_app/views/message_list.dart';
import 'package:flutter_app/views/new_message_bar.dart';
import 'package:flutter_app/views/user_info.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
            //  Provider.of<AuthenticationService>(context, listen: false)
           //       .logOut();
            },
            icon: Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: const Column(
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
