import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreenFarmer extends StatefulWidget {
  final String? chatRoomId;
  final String? userId;
  const ChatScreenFarmer(
      {required this.userId, required this.chatRoomId, super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreenFarmer> {
  final TextEditingController _messageController = TextEditingController();
  Map<String, dynamic>? userProfileData;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _getUserProfileData();
    }
  }

  Future<void> _getUserProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userProfileData = userDoc.data() as Map<String, dynamic>;
        });
      }
      // print(userProfileData);
    } catch (e) {
      print('Error fetching user profile data: $e');
    }
  }

  // Function to send a message
  Future<void> _sendMessage() async {
    try {
      String msg = _messageController.text.trim();
      if (msg.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('chatMessages')
            .doc(widget.chatRoomId)
            .collection('messages')
            .add({
          'receiverId': FirebaseAuth.instance.currentUser!.uid,
          'message': msg,
          'time': DateTime.now(),
          'receiverName': userProfileData!['name'],
          'receiverProfilePic': userProfileData!['profileImageUrl'],
          'userType': userProfileData!['userType']
        });

        setState(() {
          _messageController.clear();
        });
      }
    } catch (e) {}
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
              backgroundImage: userProfileData != null &&
                      userProfileData!['profileImageUrl'] != null
                  ? NetworkImage(userProfileData!['profileImageUrl'])
                  : const AssetImage('assets/splashImg.jpg') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                userProfileData!['name'] ?? "Chat Room",
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat message list
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
                    String senderId = messageData['senderId'] ?? '';
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
