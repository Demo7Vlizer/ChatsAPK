import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final Function(String) onSend;
  final TextEditingController _controller = TextEditingController();

  ChatInput({Key? key, required this.onSend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                onSend(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
} 