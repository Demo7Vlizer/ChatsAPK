import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/message_model.dart';

class MessageOptionsDialog extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Function(MessageModel) onDelete;

  const MessageOptionsDialog({
    Key? key,
    required this.message,
    required this.isMe,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Message Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (isMe) ...[
              _OptionButton(
                icon: Icons.delete_outline,
                label: 'Delete Message',
                color: Colors.red,
                onTap: () {
                  Get.back();
                  onDelete(message);
                },
              ),
              const Divider(),
            ],
            _OptionButton(
              icon: Icons.copy,
              label: 'Copy Message',
              onTap: () {
                // Add copy functionality
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
