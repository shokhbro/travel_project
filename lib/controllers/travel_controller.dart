import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_project/services/travel_service.dart';

class TravelController {
  final travelController = TravelService();

  Future<void> addTravel(
    String id,
    String title,
    File photo,
    String location,
  ) async {
    return travelController.addTravel(
      id,
      title,
      photo,
      location,
    );
  }

  Stream<QuerySnapshot> get list {
    return travelController.getTravel();
  }

  Future<void> updateTravel(
      String id, String title, File photo, String location) async {
    try {
      await travelController.updateTravel(id, title, photo, location);
    } catch (e) {
      print('Error updating travel: $e');
      // Handle error as needed
    }
  }

  Future<void> deleteTravel(String id) async {
    try {
      await travelController.deleteTravel(id);
    } catch (e) {
      print('Error deleting travel: $e');
      // Handle error as needed
    }
  }
}
