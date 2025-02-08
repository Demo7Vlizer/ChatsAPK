import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my/app/widgets/image_preview.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String imageUrl;

  const MessageBubble({Key? key, required this.message, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (imageUrl.isNotEmpty) _buildImageContent(imageUrl),
        ],
      ),
    );
  }

  Widget _buildImageContent(String imageUrl) {
    return GestureDetector(
      onTap: () => Get.to(() => ImagePreview(imageUrl: imageUrl)),
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => Container(
              height: 200,
              width: 200,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
            height: 200,
            width: 200,
          ),
        ),
      ),
    );
  }
} 