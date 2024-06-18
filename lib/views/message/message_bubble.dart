import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble.withUser({
    super.key,
    required this.userName,
    required this.text,
    required this.isMine,
    required this.isLast,
    this.base64ImageUrl,
  });

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.isLast,
    this.base64ImageUrl,
  }) : userName = null;

  final bool isLast;
  final String? userName;
  final String? base64ImageUrl;
  final String text;
  final bool isMine;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  static const _kDuration = Duration(milliseconds: 5000);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _kDuration,
      vsync: this,
    );

    _characterCount =
        StepTween(begin: 0, end: widget.text.length).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    if (!widget.isMine) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (!widget.isMine)
          Positioned(
            top: 16,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 12,
            ),
          ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: widget.isMine ? 0 : 24),
          child: Row(
            mainAxisAlignment:
                widget.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: widget.isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!widget.isMine && widget.userName != null)
                    const SizedBox(height: 18),
                  if (!widget.isMine && widget.userName != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 4,
                      ),
                      child: Text(
                        widget.userName!,
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
                          color: widget.isMine
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.only(
                            topLeft: !widget.isMine
                                ? Radius.zero
                                : const Radius.circular(16),
                            topRight: widget.isMine
                                ? Radius.zero
                                : const Radius.circular(16),
                            bottomLeft: widget.isMine || widget.isLast
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomRight: !widget.isMine || widget.isLast
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
                            if (widget.base64ImageUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Image.memory(
                                  Uri.parse(widget.base64ImageUrl!)
                                      .data!
                                      .contentAsBytes(),
                                ),
                              ),
                            widget.isMine
                                ? MarkdownBody(
                                    data: widget.text,
                                    styleSheet: MarkdownStyleSheet(
                                      p: TextStyle(
                                        height: 1.3,
                                        color: widget.isMine
                                            ? theme.colorScheme.onPrimary
                                            : theme
                                                .colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    softLineBreak: true,
                                  )
                                : AnimatedBuilder(
                                    animation: _characterCount,
                                    builder: (context, child) {
                                      final currentText = widget.text
                                          .substring(0, _characterCount.value);
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: MarkdownBody(
                                          data: currentText,
                                          styleSheet: MarkdownStyleSheet(
                                            p: TextStyle(
                                              height: 1.3,
                                              color: widget.isMine
                                                  ? theme.colorScheme.onPrimary
                                                  : theme.colorScheme
                                                      .onPrimaryContainer,
                                            ),
                                          ),
                                          softLineBreak: true,
                                        ),
                                      );
                                    },
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
