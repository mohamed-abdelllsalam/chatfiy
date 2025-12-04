import 'package:chatify/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBuble extends StatelessWidget {
  const ChatBuble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.senderName,
  });
  final String message;
  final bool isCurrentUser;
  final String? senderName;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final bubbleColor = isCurrentUser
        ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade500)
        : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200);
    final textColor = isCurrentUser
        ? Colors.white
        : (isDarkMode ? Colors.white : Colors.black);

    return Container(
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCurrentUser && senderName != null && senderName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                senderName!,
                style: TextStyle(
                  color: textColor.withValues(alpha: .75),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          Text(
            message,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }
}
