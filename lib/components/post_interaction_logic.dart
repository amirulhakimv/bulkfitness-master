import 'package:flutter/material.dart';

class PostInteractionLogic {
  static void toggleLike(List<Map<String, dynamic>> posts, int postIndex, String userId) {
    final post = posts[postIndex];
    final likedBy = post['likedBy'] as Set<String>;
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
      post['likes'] = (post['likes'] as int) - 1;
    } else {
      likedBy.add(userId);
      post['likes'] = (post['likes'] as int) + 1;
    }
  }

  static void addComment(List<Map<String, dynamic>> posts, int postIndex, String comment) {
    final post = posts[postIndex];
    final comments = post['comments'] as List<dynamic>;
    comments.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'username': 'CurrentUser',
      'text': comment,
      'likes': 0,
      'likedBy': <String>{},
      'replies': [],
    });
  }

  static String formatLikes(int likes) {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    } else {
      return likes.toString();
    }
  }

  static void toggleCommentLike(List<Map<String, dynamic>> posts, int postIndex, int commentIndex, String userId) {
    final comment = posts[postIndex]['comments'][commentIndex];
    final likedBy = comment['likedBy'] as Set<String>;
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
      comment['likes'] = (comment['likes'] as int) - 1;
    } else {
      likedBy.add(userId);
      comment['likes'] = (comment['likes'] as int) + 1;
    }
  }

  static void toggleReplyLike(List<Map<String, dynamic>> posts, int postIndex, int commentIndex, int replyIndex, String userId) {
    final reply = posts[postIndex]['comments'][commentIndex]['replies'][replyIndex];
    final likedBy = reply['likedBy'] as Set<String>;
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
      reply['likes'] = (reply['likes'] as int) - 1;
    } else {
      likedBy.add(userId);
      reply['likes'] = (reply['likes'] as int) + 1;
    }
  }

  static Widget buildCommentTile(
      Map<String, dynamic> comment,
      int postIndex,
      int commentIndex,
      List<Map<String, dynamic>> posts,
      Function(String, String, bool) onReply,
      StateSetter setState,
      Function(String) onViewProfile,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => onViewProfile(comment['username']),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('lib/images/default_avatar.png'),
                    radius: 16,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment['username'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  comment['text'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                constraints: BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  (comment['likedBy'] as Set<String>).contains('currentUserId')
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: (comment['likedBy'] as Set<String>).contains('currentUserId')
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 16,
                                ),
                                onPressed: () {
                                  setState(() {
                                    toggleCommentLike(posts, postIndex, commentIndex, 'currentUserId');
                                  });
                                },
                              ),
                              SizedBox(width: 4),
                              Text(
                                formatLikes(comment['likes']),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      TextButton(
                        onPressed: () {
                          onReply(comment['username'], comment['id'], false);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Reply',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...buildReplies(comment['replies'] as List<dynamic>, postIndex, commentIndex, posts, onReply, setState, onViewProfile),
        ],
      ),
    );
  }

  static List<Widget> buildReplies(
      List<dynamic> replies,
      int postIndex,
      int commentIndex,
      List<Map<String, dynamic>> posts,
      Function(String, String, bool) onReply,
      StateSetter setState,
      Function(String) onViewProfile,
      ) {
    return replies.asMap().entries.map((entry) {
      final int replyIndex = entry.key;
      final Map<String, dynamic> reply = entry.value;
      return buildReplyTile(reply, postIndex, commentIndex, replyIndex, posts, onReply, setState, onViewProfile);
    }).toList();
  }

  static Widget buildReplyTile(
      Map<String, dynamic> reply,
      int postIndex,
      int commentIndex,
      int replyIndex,
      List<Map<String, dynamic>> posts,
      Function(String, String, bool) onReply,
      StateSetter setState,
      Function(String) onViewProfile,
      ) {
    return Padding(
      padding: EdgeInsets.only(left: 40, top: replyIndex == 0 ? 16 : 8, bottom: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => onViewProfile(reply['username']),
              child: CircleAvatar(
                backgroundImage: AssetImage('lib/images/default_avatar.png'),
                radius: 12,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reply['username'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.white),
                                children: [
                                  if (reply['replyTo'] != null)
                                    TextSpan(
                                      text: '@${reply['replyTo']} ',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  TextSpan(text: reply['text']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            constraints: BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              (reply['likedBy'] as Set<String>).contains('currentUserId')
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: (reply['likedBy'] as Set<String>).contains('currentUserId')
                                  ? Colors.red
                                  : Colors.grey,
                              size: 14,
                            ),
                            onPressed: () {
                              setState(() {
                                toggleReplyLike(posts, postIndex, commentIndex, replyIndex, 'currentUserId');
                              });
                            },
                          ),
                          SizedBox(width: 4),
                          Text(
                            formatLikes(reply['likes']),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  TextButton(
                    onPressed: () {
                      onReply(reply['username'], reply['id'], true);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Reply',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildCommentInput(
      int postIndex,
      List<Map<String, dynamic>> posts,
      TextEditingController controller,
      String replyingTo,
      String replyingToId,
      bool isReplyToReply,
      StateSetter setState,
      Function() resetReplyingTo,
      ) {
    return GestureDetector(
      onTap: () {
        // This prevents the tap from propagating to the parent
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: replyingTo.isNotEmpty ? 'Reply to ${replyingTo}...' : 'Add a comment...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                style: TextStyle(color: Colors.white),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.blue),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    if (replyingTo.isEmpty) {
                      addComment(posts, postIndex, controller.text);
                    } else {
                      final comments = posts[postIndex]['comments'] as List<dynamic>;
                      if (isReplyToReply) {
                        for (var comment in comments) {
                          final replies = comment['replies'] as List<dynamic>;
                          final replyIndex = replies.indexWhere((reply) => reply['id'] == replyingToId);
                          if (replyIndex != -1) {
                            replies.add({
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'username': 'CurrentUser',
                              'text': controller.text,
                              'likes': 0,
                              'likedBy': <String>{},
                              'replyTo': replies[replyIndex]['username'],
                            });
                            break;
                          }
                        }
                      } else {
                        final commentIndex = comments.indexWhere((comment) => comment['id'] == replyingToId);
                        if (commentIndex != -1) {
                          final replies = comments[commentIndex]['replies'] as List<dynamic>;
                          replies.add({
                            'id': DateTime.now().millisecondsSinceEpoch.toString(),
                            'username': 'CurrentUser',
                            'text': controller.text,
                            'likes': 0,
                            'likedBy': <String>{},
                            'replyTo': comments[commentIndex]['username'],
                          });
                        }
                      }
                    }
                  });
                  controller.clear();
                  resetReplyingTo();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}