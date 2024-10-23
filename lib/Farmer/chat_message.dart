import 'package:flutter/material.dart';

class ChatMessageFarmer extends StatelessWidget {
  const ChatMessageFarmer({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  ChatItem(
                    name: 'Devin Glover',
                    message: 'Sent an attachment',
                    time: '14:24',
                    isRead: false,
                    imageUrl:
                        'https://via.placeholder.com/150', // Placeholder image
                  ),
                  ChatItem(
                    name: 'Steven Webb',
                    message: 'Okay, see you there than!',
                    time: '12:21',
                    isRead: true,
                    imageUrl:
                        'https://via.placeholder.com/150', // Placeholder image
                  ),
                  ChatItem(
                    name: 'Dollie Santos',
                    message: 'Same to you!',
                    time: '12:02',
                    isRead: false,
                    imageUrl:
                        'https://via.placeholder.com/150', // Placeholder image
                  ),
                  ChatItem(
                    name: 'Edith Owens',
                    message: 'Have you decided yet?',
                    time: 'Yesterday',
                    isRead: false,
                    imageUrl:
                        'https://via.placeholder.com/150', // Placeholder image
                  ),
                  ChatItem(
                    name: 'Connor Brewer',
                    message: 'Thanks!',
                    time: 'Yesterday',
                    isRead: true,
                    imageUrl:
                        'https://via.placeholder.com/150', // Placeholder image
                  ),
                  ChatItem(
                    name: 'Mary Chandler',
                    message: 'I’ll let him know',
                    time: 'Tuesday',
                    isRead: true,
                    imageUrl:
                        'https://via.placeholder.com/150', // Placeholder image
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isRead;
  final String imageUrl;

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.isRead,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: isRead ? Colors.black54 : Colors.amber,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
