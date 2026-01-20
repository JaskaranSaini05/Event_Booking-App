import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String userId;
  final String eventId;

  // Extra Event Linking Fields ✅
  final String eventTitle;
  final Timestamp eventDate;
  final String eventLocation;

  final String ticketType;
  final int seats;
  final int price;
  final int totalAmount;

  final String name;
  final String email;
  final String phone;
  final String gender;

  final String status;
  final Timestamp createdAt;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventLocation,
    required this.ticketType,
    required this.seats,
    required this.price,
    required this.totalAmount,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.status,
    required this.createdAt,
  });

  /// ✅ Convert Model → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'eventId': eventId,

      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventLocation': eventLocation,

      'ticketType': ticketType,
      'seats': seats,
      'price': price,
      'totalAmount': totalAmount,

      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,

      'status': status,
      'createdAt': createdAt,
    };
  }

  /// ✅ Convert Firestore Map → Model
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',

      eventTitle: map['eventTitle'] ?? '',
      eventDate: map['eventDate'] is Timestamp
          ? map['eventDate']
          : Timestamp.now(),
      eventLocation: map['eventLocation'] ?? '',

      ticketType: map['ticketType'] ?? '',
      seats: (map['seats'] ?? 0) is int ? map['seats'] : (map['seats'] as num).toInt(),
      price: (map['price'] ?? 0) is int ? map['price'] : (map['price'] as num).toInt(),
      totalAmount: (map['totalAmount'] ?? 0) is int
          ? map['totalAmount']
          : (map['totalAmount'] as num).toInt(),

      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',

      status: map['status'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt']
          : Timestamp.now(),
    );
  }

  /// ✅ OPTIONAL: if you want to read direct from Firestore DocumentSnapshot
  factory BookingModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel.fromMap(data);
  }
}
