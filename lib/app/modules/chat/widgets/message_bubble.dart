import 'package:flutter/material.dart';
import '../../../data/models/message_model.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Function(MessageModel) onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.onDelete,
  }) : super(key: key);

  void _showOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Message',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Message'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: message.isDeleted
                  ? Colors.grey[200]
                  : (isMe ? const Color(0xFF6C63FF) : const Color(0xFFF0F0F0)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 5),
                bottomRight: Radius.circular(isMe ? 5 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.isDeleted
                      ? 'This message was deleted'
                      : message.content,
                  style: TextStyle(
                    color: message.isDeleted
                        ? Colors.grey[600]
                        : (isMe ? Colors.white : Colors.black87),
                    fontSize: 16,
                    fontStyle:
                        message.isDeleted ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: message.isDeleted
                            ? Colors.grey[500]
                            : (isMe ? Colors.white70 : Colors.black45),
                      ),
                    ),
                    if (isMe && !message.isDeleted) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.status == MessageStatus.sent
                            ? Icons.check
                            : Icons.done_all,
                        size: 14,
                        color: message.status == MessageStatus.read
                            ? Colors.blue[200]
                            : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
