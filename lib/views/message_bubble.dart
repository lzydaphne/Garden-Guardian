import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.withUser({
    super.key,
    required this.userName,
    required this.text,
    required this.isMine,
    required this.isLast,
    this.imageUrl,
  });

  // Create a message bubble that continues the sequence.
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.isLast,
    this.imageUrl,
  }) : userName = null;

  // Whether this message bubble is the last in a sequence of messages from the same user.
  final bool isLast;

  // Username of the user. Not required if the message is not the first in a sequence.
  final String? userName;
  final String? imageUrl;
  final String text;

  // Controls how the MessageBubble will be aligned.
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (!isMine)
          Positioned(
            top: 16,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 12,
            ),
          ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: isMine ? 0 : 24),
          child: Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMine && userName != null) const SizedBox(height: 18),
                  if (!isMine && userName != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 4,
                      ),
                      child: Text(
                        userName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isMine
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.only(
                            topLeft: !isMine
                                ? Radius.zero
                                : const Radius.circular(16),
                            topRight: isMine
                                ? Radius.zero
                                : const Radius.circular(16),
                            bottomLeft: isMine || isLast
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomRight: !isMine || isLast
                                ? const Radius.circular(16)
                                : Radius.zero,
                          ),
                        ),
                        constraints: const BoxConstraints(maxWidth: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (imageUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            MarkdownBody(
                              data: text,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  height: 1.3,
                                  color: isMine
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
