import 'package:flutter/material.dart';

class MyChatPreview extends StatelessWidget {
  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  const MyChatPreview({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUnread = chat['unreadCount'] > 0;
    final DateTime lastOpened = chat['lastOpened'];
    final bool isLastMessageMine = chat['isLastMessageMine'];

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            child: Text(
              chat['username'][0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (isUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  chat['unreadCount'].toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat['username'],
        style: TextStyle(
          color: Colors.white,
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Row(
        children: [
          if (isLastMessageMine)
            Icon(Icons.check, size: 16, color: Colors.grey),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              chat['lastMessage'],
              style: TextStyle(
                color: isUnread ? Colors.white : Colors.grey,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Text(
        _formatLastOpened(lastOpened),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatLastOpened(DateTime lastOpened) {
    final now = DateTime.now();
    final difference = now.difference(lastOpened);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}