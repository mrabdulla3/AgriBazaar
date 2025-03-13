import 'package:agribazar/controllers/buyer_controller/chat_screen_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final String? chatRoomId;
  final String? userId;
  const ChatScreen({required this.userId, required this.chatRoomId, super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late ChatScreenController chatScreenController;
  @override
  void initState() {
    super.initState();
    chatScreenController = Get.put(ChatScreenController(
        userId: widget.userId, chatRoomId: widget.chatRoomId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          title: Row(
            children: [
              Obx(
                () => CircleAvatar(
                  radius: 18,
                  backgroundImage: chatScreenController.farmerProfileData !=
                              null &&
                          chatScreenController
                                  .farmerProfileData!['profileImageUrl'] !=
                              null
                      ? NetworkImage(chatScreenController
                          .farmerProfileData!['profileImageUrl'])
                      : const AssetImage('assets/splashImg.jpg')
                          as ImageProvider,
                ),
              ),
              const SizedBox(width: 10),
              Obx(
                () => Expanded(
                  child: Text(
                    chatScreenController.farmerProfileData?['name'] ??
                        "Chat Room",
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        body: Obx(
          () => chatScreenController.isLoading.value
              ? const Center(
                  child:
                      CircularProgressIndicator()) // Full screen loading indicator
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chatMessages')
                            .doc(widget.chatRoomId)
                            .collection('messages')
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          var allMessages = snapshot.data!.docs;
                          return ListView.builder(
                            padding: const EdgeInsets.all(10),
                            reverse: true,
                            itemCount: allMessages.length,
                            itemBuilder: (context, index) {
                              var messageData = allMessages[index];
                              String messageId = messageData.id;
                              String messageText = messageData['message'] ?? '';
                              String senderId = messageData['senderId'] ?? '';
                              Timestamp timestamp = messageData['time'];
                              DateTime time = timestamp.toDate();
                              bool isSentByMe = senderId ==
                                  FirebaseAuth.instance.currentUser!.uid;
                              return Align(
                                alignment: isSentByMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isSentByMe
                                        ? Colors.blue[100]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: GestureDetector(
                                    onLongPress: () {
                                      showDeleteDialog(context, messageId);
                                    },
                                    child: Column(
                                      crossAxisAlignment: isSentByMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          messageText,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "${time.hour}:${time.minute}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                                  chatScreenController.messageController,
                              decoration: InputDecoration(
                                hintText: "Type a message",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: chatScreenController.sendMessage,
                            child: const CircleAvatar(
                              backgroundColor: Colors.amberAccent,
                              radius: 25,
                              child: Icon(Icons.send, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ));
  }

  void showDeleteDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Message?"),
          actions: [
            TextButton(
              onPressed: () {
                chatScreenController
                    .deleteMessage(messageId); // Call the delete function
                Get.back();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
