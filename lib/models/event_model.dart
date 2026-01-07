import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final String description;
  final String location;
  final String organizer;
  final String organizerId;
  final int price;

  EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.description,
    required this.location,
    required this.organizer,
    required this.organizerId,
    required this.price,
  });

  factory EventModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      organizer: data['organizer'] ?? '',
      organizerId: data['organizerId'] ?? '',
      price: (data['price'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': date,
      'description': description,
      'location': location,
      'organizer': organizer,
      'organizerId': organizerId,
      'price': price,
    };
  }
}
