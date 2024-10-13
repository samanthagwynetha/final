import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('user')
        .doc(id)
        .set(userInfoMap);
  }


  Future addRoomItem(Map<String, dynamic> userInfoMap, String name) async {
    return await FirebaseFirestore.instance
        .collection(name)
        .add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getRoomItem(String name) async {
    return FirebaseFirestore.instance.collection(name).snapshots();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateRoomItem(String collectionName, String docID, Map<String, dynamic> data) async {
    await _firestore.collection(collectionName).doc(docID).update(data);
  }



  // Method to delete a room item by ID
  Future<void> deleteRoomItem(String collectionName, String docId) async {
  return await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .delete();

  }
}
