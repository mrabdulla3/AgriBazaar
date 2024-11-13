import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ChatScreen extends StatefulWidget {
  final String? chatRoomId;
  final String? userId;
  const ChatScreen({required this.userId, required this.chatRoomId, super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  Map<String, dynamic>? farmerProfileData;
  Map<String, dynamic>? currentUserProfileData;
  bool isLoading = true; // Loading state variable
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    if (widget.userId != null && widget.chatRoomId != null) {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });

    await _getFarmerProfileData();
    await _getCurrentProfileData();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getFarmerProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          farmerProfileData = userDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      logger.e('Error fetching farmer profile data: $e');
    }
  }

  Future<void> _getCurrentProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          currentUserProfileData = userDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      logger.e('Error fetching current user profile data: $e');
    }
  }

  // Function to send a message
  Future<void> _sendMessage() async {
    try {
      String msg = _messageController.text.trim();
      if (msg.isNotEmpty) {
        // Check if the chat room document exists
        DocumentReference chatRoomRef = FirebaseFirestore.instance
            .collection('chatMessages')
            .doc(widget.chatRoomId);

        DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

        // If the document does not exist, create it
        if (!chatRoomSnapshot.exists) {
          await chatRoomRef.set({
            'created_at': FieldValue.serverTimestamp(),
            'participants': [
              FirebaseAuth.instance.currentUser!.uid,
              widget.userId
            ],
          });
        }

        // Now add the message to the messages subcollection
        await chatRoomRef.collection('messages').add({
          'senderId': FirebaseAuth.instance.currentUser!.uid,
          'message': msg,
          'time': DateTime.now(),
          'senderName': currentUserProfileData!['name'],
          'senderProfilePic': currentUserProfileData!['profileImageUrl'],
          'userType': farmerProfileData!['userType'],
        });

        setState(() {
          _messageController.clear();
        });
      }
    } catch (e) {
      logger.e('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: farmerProfileData != null &&
                      farmerProfileData!['profileImageUrl'] != null
                  ? NetworkImage(farmerProfileData!['profileImageUrl'])
                  : const AssetImage('assets/splashImg.jpg') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                farmerProfileData?['name'] ?? "Chat Room",
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var allMessages = snapshot.data!.docs;
                      return ListView.builder(
                        padding: const EdgeInsets.all(10),
                        reverse: true,
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          var messageData = allMessages[index];
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
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: isSentByMe
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
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
                        onTap: _sendMessage,
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
