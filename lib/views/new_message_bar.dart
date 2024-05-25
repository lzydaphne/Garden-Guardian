import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/view_models/all_messages_vm.dart';
import 'package:provider/provider.dart';

class NewMessageBar extends StatefulWidget {
  const NewMessageBar({super.key});

  @override
  State<NewMessageBar> createState() {
    return _NewMessageBarState();
  }
}

class _NewMessageBarState extends State<NewMessageBar> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final allMessagesViewModel = Provider.of<AllMessagesViewModel>(context, listen: false);
    
    allMessagesViewModel.addMessage(
      Message(
        text: enteredMessage,
        // userId: me.id,
        userName: "ME",
        // userAvatarUrl: me.avatarUrl,
      )
    );
  }

  @override
Widget build(BuildContext context) {
  return Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
        child: Row(
          children: [
            
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  prefixIcon: Padding(padding : const EdgeInsets.only(left:5),
                    child : IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      // Handle camera icon press
                    },
                  )),
                  hintText: 'Enter something',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                ),
              ),
            ),
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(
                  Icons.send,
                ),
                onPressed: _submitMessage
                )
          ],
        ),
      );
}

}
