import 'package:agribazar/controllers/farmer_controller/chat_screen_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class ChatScreenFarmer extends StatelessWidget {
  final String? chatRoomId;
  final String? userId;

  ChatScreenFarmer({super.key, required this.userId, required this.chatRoomId});

  

  @override
  Widget build(BuildContext context) {
    // Inject userId and chatRoomId into the controller
    final chatController = Get.put(ChatScreenController(userId, chatRoomId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Obx(() {
          final profile = chatController.userProfileData;
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: profile['profileImageUrl'] != null
                    ? NetworkImage(profile['profileImageUrl'])
                    : const AssetImage('assets/splashImg.jpg') as ImageProvider,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  profile['name'] ?? "Chat Room",
                  style: GoogleFonts.abhayaLibre(
                    textStyle: const TextStyle(
                        fontSize: 18,
                        letterSpacing: .5,
                        fontWeight: FontWeight.w700),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          // Chat message list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatMessages')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }
                var allMessages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  reverse: true,
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    var messageData = allMessages[index];
                    String messageText = messageData['message'] ?? '';
                    String senderId = messageData['receiverId'] ?? '';
                    Timestamp timestamp = messageData['time'];
                    DateTime time = timestamp.toDate();
                    bool isSentByMe =
                        senderId == FirebaseAuth.instance.currentUser!.uid;

                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              isSentByMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                    );
                  },
                );
              },
            ),
          ),
          // Message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController.messageController,
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
                  onTap: () => chatController.sendMessage(),
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
    );
  }
}
