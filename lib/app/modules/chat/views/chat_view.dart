import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:my/app/data/models/message_model.dart';
import 'package:my/app/widgets/keyboard_dismiss.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_input.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my/app/modules/image_preview/views/image_preview.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    void scrollToBottom() {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeOut,
        );
      }
    }

    return Obx(() {
      if (controller.isInitialized.value == false) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(Get.arguments['userPhoto'] as String? ?? ''),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Get.arguments['userName'] as String? ?? 'Chat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Obx(() => Text(
                            controller.isOtherUserOnline.value
                                ? 'Online'
                                : 'Offline',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          )),
                      StreamBuilder<bool>(
                        stream:
                            controller.getTypingStatus(controller.otherUserId),
                        builder: (context, snapshot) {
                          if (snapshot.data == true) {
                            return const Text(
                              ' • typing...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: KeyboardDismissOnTap(
            child: Column(
              children: [
                Obx(() => controller.isLoading.value
                    ? const LinearProgressIndicator(
                        backgroundColor: Color(0xFF6C63FF),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const SizedBox.shrink()),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Obx(() {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (controller.messages.isNotEmpty) {
                          scrollToBottom();
                        }
                      });
                      return ListView.builder(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        reverse: false,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 5,
                          bottom: 5,
                        ),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          final isMe =
                              message.senderId == controller.currentUserId;
                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                            onLongPress: isMe
                                ? () => controller.deleteMessage(message)
                                : null,
                            imageUrl: message.type == MessageType.image
                                ? message.content
                                : '',
                          );
                        },
                      );
                    }),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: ChatInput(
                      onTextChanged: (text) {
                        if (text.isNotEmpty) {
                          controller.updateTypingStatus(
                              controller.otherUserId, true);
                        } else {
                          controller.updateTypingStatus(
                              controller.otherUserId, false);
                        }
                      },
                      onSendPressed: (text) {
                        controller.sendMessage(
                            controller.otherUserId, text, MessageType.text);
                      },
                      onImageSelected: (file) {
                        controller.sendImage(file);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
      );
    });
  }
}

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onLongPress;
  final String imageUrl;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.onLongPress,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF6C63FF) : const Color(0xFFF0F0F0),
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
                if (message.type == MessageType.image)
                  GestureDetector(
                    onTap: () => Get.to(() => ImagePreview(imageUrl: imageUrl)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
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
                        color: isMe ? Colors.white70 : Colors.black45,
                      ),
                    ),
                    if (isMe) ...[
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
