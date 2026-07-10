import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Every read/write in the app goes through this class.
/// Data is stored under users/{uid}/{collectionName}, so:
///  - each user only ever sees their own records
///  - Firestore security rules become a one-line check
///  - Firestore's built-in offline cache + auto-sync just works,
///    no extra local-storage layer needed.
class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> collection(String name) {
    final uid = _uid;
    if (uid == null) {
      throw StateError('No authenticated user — cannot access "$name"');
    }
    return _db.collection('users').doc(uid).collection(name);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> stream(
    String name, {
    String orderBy = 'createdAt',
    bool descending = true,
  }) {
    return collection(name)
        .orderBy(orderBy, descending: descending)
        .snapshots();
  }

  static Future<void> add(String name, Map<String, dynamic> data) {
    return collection(name).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> delete(String name, String docId) {
    return collection(name).doc(docId).delete();
  }
}
