import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jaytap/shared/extensions/extensions.dart';

import '../views/chat_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(20);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isMe ? context.primaryColor : context.greyColor.withOpacity(.2),
            borderRadius: isMe ? borderRadius.subtract(BorderRadius.only(bottomRight: radius)) : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: _buildMessageContent(),
        ),
      ],
    );
  }

  Widget _buildMessageContent() {
    if (message.type == MessageType.image && message.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          File(message.imagePath!),
          fit: BoxFit.cover,
        ),
      );
    }
    return Text(
      message.content,
      style: TextStyle(color: isMe ? Colors.white : Colors.black),
    );
  }
}
