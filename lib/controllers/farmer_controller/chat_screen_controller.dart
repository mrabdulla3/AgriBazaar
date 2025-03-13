import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ChatScreenController extends GetxController{
  String ?chatRoomId;
  String ?userId;
  ChatScreenController(this.userId,this.chatRoomId);
   
  @override
  void onInit() {
    super.onInit();
    if (userId != null){
       getUserProfileData();
    }
    
  }
  
  TextEditingController messageController = TextEditingController();
  RxMap<String, dynamic> userProfileData = <String, dynamic>{}.obs;
  var logger = Logger();
  
    Future<void> getUserProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        
          userProfileData.value = userDoc.data() as Map<String, dynamic>;
       
      }
      // print(userProfileData);
    } catch (e) {
      logger.e('Error fetching user profile data: $e');
    }
  }


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
            'participants': [
              FirebaseAuth.instance.currentUser!.uid,
              userId
            ],
          });
        }

        // Now add the message to the messages subcollection
        await chatRoomRef.collection('messages').add({
          'receiverId': FirebaseAuth.instance.currentUser!.uid,
          'message': msg,
          'time': DateTime.now(),
          'receiverName': userProfileData['name'],
          'receiverProfilePic': userProfileData['profileImageUrl'],
          'userType': userProfileData['userType']
        });

       
        messageController.clear();
       
      }
    } catch (e) {
      logger.e('Error sending message: $e');
    }
  }
}