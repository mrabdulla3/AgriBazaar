import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ChatScreenController extends GetxController {
  ChatScreenController({required this.userId, required this.chatRoomId});
  String? userId;
  String? chatRoomId;
  final TextEditingController messageController = TextEditingController();
  RxMap<String, dynamic>? farmerProfileData = <String, dynamic>{}.obs;
  RxMap<String, dynamic>? currentUserProfileData = <String, dynamic>{}.obs;
  RxBool isLoading = true.obs; // Loading state variable
  Logger logger = Logger();

  @override
  void onInit() {
    super.onInit();
    if (userId != null && chatRoomId != null) {
      initializeData();
    }
  }

  Future<void> initializeData() async {
    isLoading.value = true;

    await getFarmerProfileData();
    await getCurrentProfileData();

    isLoading.value = false;
  }

  Future<void> getFarmerProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        farmerProfileData!.value = userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      logger.e('Error fetching farmer profile data: $e');
    }
  }

  Future<void> getCurrentProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        currentUserProfileData!.value = userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      logger.e('Error fetching current user profile data: $e');
    }
  }

  // Function to send a message
  Future<void> sendMessage() async {
    try {
      String msg = messageController.text.trim();
      if (msg.isNotEmpty) {
        // Check if the chat room document exists
        DocumentReference chatRoomRef = FirebaseFirestore.instance
            .collection('chatMessages')
            .doc(chatRoomId);

        DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();
        // If the document does not exist, create it
        if (!chatRoomSnapshot.exists) {
          await chatRoomRef.set({
            'created_at': FieldValue.serverTimestamp(),
            'participants': [FirebaseAuth.instance.currentUser!.uid, userId],
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
        messageController.clear();
      }
    } catch (e) {
      logger.e('Error sending message: $e');
    }
  }
}
