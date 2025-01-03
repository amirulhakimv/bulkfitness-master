import 'package:flutter/material.dart';

class MyUserSuggestion extends StatelessWidget {
  final String username;
  final bool isFollowing;
  final VoidCallback onFollowToggle;
  final VoidCallback onViewProfile;

  const MyUserSuggestion({
    Key? key,
    required this.username,
    required this.isFollowing,
    required this.onFollowToggle,
    required this.onViewProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewProfile,
      child: Container(
        width: 150,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[800],
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                username,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: onFollowToggle,
                child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? Colors.grey : Colors.blue,
                  minimumSize: Size(120, 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}