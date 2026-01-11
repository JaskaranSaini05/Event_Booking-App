import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String category;

  // OLD (string date – keep for backward compatibility)
  final String date;

  // NEW (proper time)
  final DateTime? eventTime;

  final String description;

  // Address shown in UI
  final String location;

  // Map coordinates
  final double? latitude;
  final double? longitude;

  final String organizer;
  final String organizerId;
  final int price;

  EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.eventTime,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.organizer,
    required this.organizerId,
    required this.price,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      date: data['date'] ?? '',

      // Timestamp → DateTime (SAFE)
      eventTime: data['eventTime'] != null
          ? (data['eventTime'] as Timestamp).toDate()
          : null,

      description: data['description'] ?? '',
      location: data['location'] ?? '',

      latitude: data['latitude'] != null
          ? (data['latitude'] as num).toDouble()
          : null,

      longitude: data['longitude'] != null
          ? (data['longitude'] as num).toDouble()
          : null,

      organizer: data['organizer'] ?? '',
      organizerId: data['organizerId'] ?? '',
      price: (data['price'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': date, // keep old string
      'eventTime':
          eventTime != null ? Timestamp.fromDate(eventTime!) : null,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'organizer': organizer,
      'organizerId': organizerId,
      'price': price,
    };
  }
}
