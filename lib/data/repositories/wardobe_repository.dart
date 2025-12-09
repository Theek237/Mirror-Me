import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mm/data/models/user_clothing_item.dart';

class WardobeRepository {
  final CollectionReference _clothsCollection = FirebaseFirestore.instance.collection('cloths');


  //Function to add a clothing item to Firestore
  Future<void> addClothingItem(UserClothingItem item) async {
    try{
      await _clothsCollection.doc(item.itemId).set(item.toMap());
    } catch (e) {
      throw Exception('Failed to add clothing item: $e');
    }
  }

  //Function to get all clothing items for a specific user
  Future<List<UserClothingItem>> getUserClothes(String userId) async{
    try{
      final snapshot = await _clothsCollection.where('userId',isEqualTo: userId).get();
      return snapshot.docs.map((doc){
        return UserClothingItem.fromMap(doc.data() as Map<String,dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user clothes: $e');
    }
  }

  
}