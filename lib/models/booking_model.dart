import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String userId;
  final String eventId;
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

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'eventId': eventId,
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

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      ticketType: map['ticketType'] ?? '',
      seats: map['seats'] ?? 0,
      price: map['price'] ?? 0,
      totalAmount: map['totalAmount'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
