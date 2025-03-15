import 'package:agribazar/controllers/buyer_controller/chat_userlist_controller.dart';
import 'package:agribazar/views/buyer_views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatMessageBuyer extends StatefulWidget {
  const ChatMessageBuyer({super.key});

  @override
  State<ChatMessageBuyer> createState() => _ChatMessageBuyerState();
}

class _ChatMessageBuyerState extends State<ChatMessageBuyer> {
  ChatUserlistController chatUserlistController =
      Get.put(ChatUserlistController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Obx(
          () => chatUserlistController.isSearching.value
              ? TextField(
                  controller: chatUserlistController.searchController,
                  autofocus: true,
                  onChanged: (value) {
                    chatUserlistController.searchQuery.value =
                        value.toLowerCase();
                  },
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search messages...",
                    hintStyle: const TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black),
                      onPressed: () {
                        chatUserlistController.searchController.clear();
                        chatUserlistController.searchQuery.value = '';
                        chatUserlistController.isSearching.value = false;
                      },
                    ),
                  ),
                )
              : const Text(
                  'Messages',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => (!chatUserlistController.isSearching.value)
              ? IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    chatUserlistController.isSearching.value = true;
                  },
                )
              : const SizedBox())
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
                    return doc.id.startsWith(chatUserlistController.buyerId);
                  }).toList();
                  // Check if filtered rooms are empty
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
                      // Filter messages based on the search term
                      return Obx(() {
                        List<ChatMessage> displayedMessages = messagesSnapshot
                            .data!
                            .where((message) =>
                                message.username.toLowerCase().contains(
                                    chatUserlistController.searchQuery.value) ||
                                message.message.toLowerCase().contains(
                                    chatUserlistController.searchQuery.value))
                            .toList();

                        if (displayedMessages.isEmpty) {
                          return const Center(child: Text("No messages found"));
                        }

                        return ListView(
                          children: (displayedMessages.isNotEmpty
                                  ? displayedMessages
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
                      });
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

  // Fetch messages from each chat room
  Future<List<ChatMessage>> _fetchMessagesForChatRooms(
      List<QueryDocumentSnapshot> filteredRooms) async {
    List<ChatMessage> uniqueMessages = [];

    for (var room in filteredRooms) {
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection('chatMessages')
          .doc(room.id)
          .collection('messages')
          .where('senderId', isNotEqualTo: chatUserlistController.buyerId)
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
      return "No Time"; // Placeholder text if timestamp is missing
    }

    try {
      DateTime dateTime = (timestamp as Timestamp).toDate();
      return "${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return "Invalid Time"; // Fallback if the conversion fails
    }
  }
}

class ChatMessage {
  final String username;
  final String message;
  final dynamic time; // Change to dynamic for flexibility
  final bool isRead;
  final String buyerImageUrl;
  final String senderId; // Add senderId
  final String chatRoomId; // Add chatRoomId

  ChatMessage({
    required this.username,
    required this.message,
    required this.time,
    required this.isRead,
    required this.buyerImageUrl,
    required this.senderId,
    required this.chatRoomId, // Include chatRoomId in constructor
  });
}

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isRead;
  final String imageUrl;
  final String senderId;
  final String chatRoomId; // Include chatRoomId

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.isRead,
    required this.imageUrl,
    required this.senderId,
    required this.chatRoomId, // Include chatRoomId in constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ensure to navigate with the correct userId and chatRoomId
        //print(senderId);
        //print(chatRoomId);
        Get.to(
          () => ChatScreen(
            userId: senderId, // Pass senderId directly
            chatRoomId: chatRoomId, // Use the correct chatRoomId
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
      ),
    );
  }
}
