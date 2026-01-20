import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import 'payment_method_screen.dart';

// ============================================================================
// CONSTANTS
// ============================================================================
class AppTheme {
  static const primary = Colors.deepOrange;
  static const background = Color(0xFFF8F9FA);
  static const cardBg = Colors.white;
  static const textDark = Color(0xFF212121);
  static const textGrey = Color(0xFF757575);
  static const divider = Color(0xFFE0E0E0);
}

// ============================================================================
// MAIN SCREEN
// ============================================================================
class ReviewTicketSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> ticketData;
  final String eventId;

  const ReviewTicketSummaryScreen({
    super.key,
    required this.ticketData,
    required this.eventId,
  });

  Future<Map<String, dynamic>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  Future<EventModel> _getEventData() async {
    final doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    return EventModel.fromFirestore(doc);
  }

  String _formatDateTime(EventModel event) {
    if (event.eventTime != null) {
      return DateFormat('MMM d, yyyy • h:mm a').format(event.eventTime!);
    }
    return event.date;
  }

  int _calculateGST(int amount) => ((amount) * 0.18).round();

  @override
  Widget build(BuildContext context) {
    final ticketType = ticketData['ticketType'] ?? '';
    final seats = ticketData['seats'] ?? 1;
    final price = ticketData['price'] ?? 0;
    final totalAmount = ticketData['totalAmount'] ?? price * seats;
    final convenienceFee = 15;
    final gst = _calculateGST(totalAmount + convenienceFee);
    final grandTotal = totalAmount + convenienceFee + gst;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: FutureBuilder(
        future: Future.wait([_getUserData(), _getEventData()]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final user = snapshot.data![0] as Map<String, dynamic>;
          final event = snapshot.data![1] as EventModel;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EventCard(event: event, formatDateTime: _formatDateTime),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Booking Details'),
                      const SizedBox(height: 16),
                      _UserInfoCard(user: user),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Price Details'),
                      const SizedBox(height: 16),
                      _PriceCard(
                        ticketType: ticketType,
                        seats: seats,
                        price: price,
                        totalAmount: totalAmount,
                        convenienceFee: convenienceFee,
                        gst: gst,
                        grandTotal: grandTotal,
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, grandTotal),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.cardBg,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Review Summary',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, int grandTotal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentMethodScreen(totalAmount: grandTotal),
                ),
              );
            },
            child: const Text(
              'Proceed to Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// REUSABLE COMPONENTS
// ============================================================================
class _EventCard extends StatelessWidget {
  final EventModel event;
  final String Function(EventModel) formatDateTime;

  const _EventCard({required this.event, required this.formatDateTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14',
              width: 100,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 130,
                color: Colors.grey[300],
                child: const Icon(Icons.event, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildEventInfo(Icons.person_outline, event.organizer),
                const SizedBox(height: 4),
                _buildEventInfo(Icons.access_time, formatDateTime(event)),
                const SizedBox(height: 4),
                _buildEventInfo(Icons.location_on_outlined, event.location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Full Name', user['name'] ?? ''),
          const SizedBox(height: 12),
          _buildInfoRow('Phone', user['phone'] ?? ''),
          const SizedBox(height: 12),
          _buildInfoRow('Email', user['email'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String ticketType;
  final int seats;
  final int price;
  final int totalAmount;
  final int convenienceFee;
  final int gst;
  final int grandTotal;

  const _PriceCard({
    required this.ticketType,
    required this.seats,
    required this.price,
    required this.totalAmount,
    required this.convenienceFee,
    required this.gst,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('$ticketType Ticket × $seats', totalAmount),
          const SizedBox(height: 12),
          _buildPriceRow('Convenience Fee', convenienceFee),
          const SizedBox(height: 12),
          _buildPriceRow('GST (18%)', gst),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 16),
          _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
        ),
        Text(
          '₹$amount',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Grand Total',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            '₹$grandTotal',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}