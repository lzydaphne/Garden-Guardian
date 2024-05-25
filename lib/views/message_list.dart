import 'package:flutter/material.dart';
import 'package:flutter_app/view_models/all_messages_vm.dart';
import 'package:flutter_app/models/user.dart';
// import 'package:flutter_app/view_models/me_vm.dart';
import 'package:flutter_app/views/message_bubble.dart';
import 'package:provider/provider.dart';
class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    //final meViewModel = Provider.of<MeViewModel>(context);
    final allMessagesViewModel = Provider.of<AllMessagesViewModel>(context);

    final me = User("ME");
    final messages = allMessagesViewModel.messages;

    if (messages.isEmpty) {
      return const Center(
        child: Text('No messages.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 16,
        left: 8,
        right: 8,
      ),
      reverse: false,
      itemCount: messages.length,
      itemBuilder: (ctx, index) {
        final message = messages[index];
        final nextMessage =
            index + 1 < messages.length ? messages[index + 1] : null;
        final prevMessage = index - 1 >= 0 ? messages[index - 1] : null;

        final messageUsername = message.userName ;
        final nextMessageUsername= nextMessage?.userName;
        final isNextUserSame = nextMessageUsername== messageUsername;
        final preMessageUserId = prevMessage?.userName;
        final isPreUserSame = preMessageUserId == messageUsername;

        if (isNextUserSame) {
          return MessageBubble(
            text: message.text,
            isMine: me.userName == messageUsername,
            isLast: !isPreUserSame,
          );
        } else {
          return MessageBubble.withUser(
            userName: message.userName,
            text: message.text,
            isMine: me.userName == messageUsername,
            isLast: !isPreUserSame,
          );
        }
      },
    );
  }
}
