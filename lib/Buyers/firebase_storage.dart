import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Method to fetch image URL from Firebase Storage
  Future<String> getImageUrl(String imagePath) async {
    try {
      return await _storage.ref(imagePath).getDownloadURL();
    } catch (e) {
      print("Error fetching image: $e");
      return '';
    }
  }

  // Method to fetch all required images
  Future<Map<String, String?>> fetchImages() async {
    Map<String, String?> imageUrls = {};

    imageUrls['capsicumImageUrl'] = await getImageUrl('Capsicum.jpg');
    imageUrls['onionImageUrl'] = await getImageUrl('Onion.jpg');
    imageUrls['wheatImageUrl'] = await getImageUrl('Wheat.jpg');
    imageUrls['trendingImageUrl'] = await getImageUrl('trending.jpg');

    return imageUrls;
  }
}
