import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TravelService {
  final _travelCollection = FirebaseFirestore.instance.collection('travel');
  final _travelPhotoStorage = FirebaseStorage.instance;
  Future<void> addTravel(
      String id, String title, File photo, String location) async {
    final photoReference =
        _travelPhotoStorage.ref().child('images').child('$title.jpg');

    final uploadTask = photoReference.putFile(photo);
    await uploadTask.whenComplete(() async {
      final imageUrl = await photoReference.getDownloadURL();
      await _travelCollection.add({
        'id': id,
        'title': title,
        'photo': imageUrl,
        'location': location,
      });
    });
  }

  Stream<QuerySnapshot> getTravel() async* {
    yield* _travelCollection.snapshots();
  }

  Future<void> updateTravel(
      String id, String title, File photo, String location) async {
    try {
      if (photo != null) {
        final photoReference =
            _travelPhotoStorage.ref().child('images').child('$title.jpg');
        final uploadTask = photoReference.putFile(photo);
        await uploadTask.whenComplete(() async {
          final imageUrl = await photoReference.getDownloadURL();
          await _travelCollection.doc(id).update({
            'title': title,
            'photo': imageUrl,
            'location': location,
          });
        });
      } else {
        await _travelCollection.doc(id).update({
          'title': title,
          'location': location,
        });
      }
    } catch (e) {
      print('Error updating travel: $e');
      // Handle error as needed
    }
  }

  Future<void> deleteTravel(String id) async {
    try {
      await _travelCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting travel: $e');
      // Handle error as needed
    }
  }
}
