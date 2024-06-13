import 'package:flutter/material.dart';
import 'package:flutter_app/view_models/all_messages_vm.dart';
import 'package:flutter_app/models/user.dart';
// import 'package:flutter_app/view_models/me_vm.dart';
import 'package:flutter_app/views/message_bubble.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/message.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});
  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // Scroll to bottom whenever a new message is added
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          // At the bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // void addMessage(String message) {
  //   final allMessagesViewModel = Provider.of<AllMessagesViewModel>(context);
  //   setState(() {
  //     allMessagesViewModel.addBotMessage(message);
  //     // msgList.add(Message(text: message, userName: "BOT"));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final allMessagesViewModel = Provider.of<AllMessagesViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (allMessagesViewModel.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    final me = User("ME");
    final messages = allMessagesViewModel.messages;

    if (messages.isEmpty) {
      return const Center(
        child: Text('No messages.'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
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

        final messageUsername = message.userName;
        final nextMessageUsername = nextMessage?.userName;
        final isNextUserSame = nextMessageUsername == messageUsername;
        final preMessageUserId = prevMessage?.userName;
        final isPreUserSame = preMessageUserId == messageUsername;
        final imageUrl = message.imageUrl;

        if (isNextUserSame) {
          return MessageBubble(
            text: message.text,
            isMine: me.userName == messageUsername,
            isLast: !isPreUserSame,
            imageUrl: imageUrl,
          );
        } else {
          return MessageBubble.withUser(
            userName: message.userName,
            text: message.text,
            isMine: me.userName == messageUsername,
            isLast: !isPreUserSame,
            imageUrl: imageUrl,
          );
        }
      },
    );
  }
}
