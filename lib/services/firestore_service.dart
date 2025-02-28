import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_upload/models/candidate.dart';
import 'package:easy_upload/models/document.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save candidate info to Firestore
  Future<void> saveCandidateInfo(Candidate candidate) async {
    
    await _firestore.collection('users').doc(candidate.id).set(candidate.toJson());
  }

  // Upload document to Firebase Storage and save metadata to Firestore
  Future<void> uploadDocument(String candidateId, PlatformFile file) async {
    try {
      // Upload file to Firebase Storage
      final Reference storageRef = _storage.ref().child('documents/$candidateId/${file.name}');
      await storageRef.putFile(File(file.path!));

      // Get download URL
      final String downloadURL = await storageRef.getDownloadURL();

      // Save document metadata to Firestore
      final Document document = Document(
        id: DateTime.now().toString(),
        name: file.name,
        filePath: downloadURL,
        uploadDate: DateTime.now(),
        status: "Pending",
        candidateId: candidateId
      );

      await _firestore.collection('candidates').doc(candidateId).update({
        'documents': FieldValue.arrayUnion([document.toJson()]),
      });
    } catch (e) {
      print("Error uploading document: $e");
    }
  }

  // Get candidate documents from Firestore
  Future<List<Document>> getDocuments(String candidateId) async {
    final DocumentSnapshot snapshot = await _firestore.collection('users').doc(candidateId).get();
    final List<dynamic> documentsJson = snapshot.get('documents');
    return documentsJson.map((doc) => Document.fromJson(doc)).toList();
  }
}