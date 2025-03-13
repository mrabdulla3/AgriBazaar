import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:logger/logger.dart';

class OurProductsController extends GetxController{

  RxList<Map<String, dynamic>> productList = <Map<String, dynamic>>[].obs;
  RxString errorMessage = ''.obs;
  var logger = Logger();
  RxBool isLoading = true.obs;

  Future<void> getOurProducts() async {
    try {
      QuerySnapshot items = await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      
        productList.value = items.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      
    } catch (e) {
      errorMessage.value = 'Error fetching products: $e';
    }
    finally{
      isLoading.value=false;
    }
  }
  
    Future<void> deleteItem(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .doc(productId)
          .delete();
     
        productList.removeWhere((product) => product['id'] == productId);
      
    } catch (e) {
      logger.e("Error deleting product: $e");
    }
  }
}