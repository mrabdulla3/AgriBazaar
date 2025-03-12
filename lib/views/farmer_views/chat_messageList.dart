import 'package:agribazar/Buyers/chat_screen.dart';
import 'package:agribazar/controllers/farmer_controller/chat_message_controller.dart';
import 'package:agribazar/views/buyer_views/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessageFarmer extends StatefulWidget {
  const ChatMessageFarmer({super.key});

  @override
  State<ChatMessageFarmer> createState() => _ChatMessageFarmerState();
}

class _ChatMessageFarmerState extends State<ChatMessageFarmer> {
  final chatMessage = Get.put(ChatMessageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: chatMessage.isSearching.value
            ? TextField(
                autocorrect: true,
                autofocus: true,
                onChanged: (value) {
                  
                    chatMessage.searchQuery.value = value.toLowerCase();
                  
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search message...',
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        searchQuery = '';
                        isSearching = false;
                      });
                    },
                  ),
                ),
              )
            : Text(
                'Messages',
                style: GoogleFonts.abhayaLibre(
                  textStyle: const TextStyle(
                      fontSize: 22,
                      letterSpacing: .5,
                      fontWeight: FontWeight.w700),
                ),
              ),
        centerTitle: true,
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatMessages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter chat room documents where the document ID ends with farmerId
                  final filteredRooms = snapshot.data!.docs.where((doc) {
                    return doc.id.endsWith(farmerId);
                  }).toList();

                  if (filteredRooms.isEmpty) {
                    return const Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hourglass_empty_outlined,
                              size: 70,
                            ),
                            Text("No messages for this farmer yet")
                          ]),
                    );
                  }

                  // Fetch messages for each filtered chat room
                  return FutureBuilder<List<ChatMessage>>(
                    future: _fetchMessagesForChatRooms(filteredRooms),
                    builder: (context, messagesSnapshot) {
                      if (messagesSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (messagesSnapshot.hasError) {
                        return const Center(
                            child: Text("Error fetching messages"));
                      }

                      if (!messagesSnapshot.hasData ||
                          messagesSnapshot.data!.isEmpty) {
                        return const Center(child: Text("No messages found"));
                      }

                      List<ChatMessage> displaySearchedMessage =
                          messagesSnapshot.data!
                              .where((message) =>
                                  message.username
                                      .toLowerCase()
                                      .contains(searchQuery) ||
                                  message.message
                                      .toLowerCase()
                                      .contains(searchQuery))
                              .toList();

                      if (displaySearchedMessage.isEmpty) {
                        return const Center(child: Text("No messages found"));
                      }

                      return ListView(
                        children: (displaySearchedMessage.isNotEmpty
                                ? displaySearchedMessage
                                : messagesSnapshot.data!)
                            .map((message) {
                          return ChatItem(
                            name: message.username,
                            message: message.message,
                            time: formatTime(message.time),
                            isRead: message.isRead,
                            imageUrl: message.buyerImageUrl,
                            senderId: message.senderId,
                            chatRoomId: message.chatRoomId,
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch messages from each chat room and keep only the latest message from each senderId
  Future<List<ChatMessage>> _fetchMessagesForChatRooms(
      List<QueryDocumentSnapshot> filteredRooms) async {
    List<ChatMessage> uniqueMessages = [];

    for (var room in filteredRooms) {
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection('chatMessages')
          .doc(room.id)
          .collection('messages')
          .where('senderId', isNotEqualTo: farmerId)
          .get();

      // Map to store latest message per senderId
      Map<String, ChatMessage> latestMessagesBySender = {};

      for (var m in messageSnapshot.docs) {
        var data = m.data() as Map<String, dynamic>;
        String senderId = data['senderId'];

        // If senderId is not yet in the map, add the latest message
        if (!latestMessagesBySender.containsKey(senderId)) {
          latestMessagesBySender[senderId] = ChatMessage(
            username: data['senderName'] ?? 'Unknown Buyer',
            message: data['message'] ?? 'No message content',
            time: data['time'] ?? Timestamp.now(),
            isRead: data['isRead'] ?? false,
            buyerImageUrl:
                data['senderProfilePic'] ?? 'https://via.placeholder.com/150',
            senderId: senderId,
            chatRoomId: room.id,
          );
        }
      }

      // Add unique messages from the current room to the main list
      uniqueMessages.addAll(latestMessagesBySender.values);
    }

    return uniqueMessages;
  }

  // Helper function to format the timestamp
  String formatTime(dynamic timestamp) {
    if (timestamp == null) {
      return "No Time";
    }
    try {
      DateTime dateTime = (timestamp as Timestamp).toDate();
      return "${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return "Invalid Time";
    }
  }
}

class ChatMessage {
  final String username;
  final String message;
  final dynamic time;
  final bool isRead;
  final String buyerImageUrl;
  final String senderId;
  final String chatRoomId;

  ChatMessage({
    required this.username,
    required this.message,
    required this.time,
    required this.isRead,
    required this.buyerImageUrl,
    required this.senderId,
    required this.chatRoomId,
  });
}

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isRead;
  final String imageUrl;
  final String senderId;
  final String chatRoomId;

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.isRead,
    required this.imageUrl,
    required this.senderId,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userId: senderId,
              chatRoomId: chatRoomId,
            ),
          ),
        );
      },
      child: Container(
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
                    style: GoogleFonts.abhayaLibre(
                      textStyle: const TextStyle(
                          fontSize: 19,
                          letterSpacing: .5,
                          fontWeight: FontWeight.w700),
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
      ),
    );
  }
}