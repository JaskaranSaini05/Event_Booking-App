import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../events/event_detail_screen.dart';
import '../home/home_screen.dart';
import '../home/explore_screen.dart';
import '../home/favorite_screen.dart';
import '../profile/profile_screen.dart';

// ============================================================================
// CONSTANTS
// ============================================================================
class TicketTheme {
  static const primary = Colors.deepOrange;
  static const background = Color(0xFFF5F5F5);
  static const cardBg = Colors.white;
  static const textDark = Color(0xFF212121);
  static const textGrey = Color(0xFF757575);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
}

// ============================================================================
// MODELS
// ============================================================================
class BookingData {
  final String bookingId;
  final String eventId;
  final String ticketType;
  final int seats;
  final int totalAmount;
  final String status;
  final DateTime? createdAt;

  BookingData({
    required this.bookingId,
    required this.eventId,
    required this.ticketType,
    required this.seats,
    required this.totalAmount,
    required this.status,
    this.createdAt,
  });

  factory BookingData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingData(
      bookingId: doc.id,
      eventId: data['eventId'] ?? '',
      ticketType: data['ticketType'] ?? 'Regular',
      seats: data['seats'] ?? 1,
      totalAmount: data['totalAmount'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}

class EventData {
  final String eventId;
  final String title;
  final String category;
  final String location;
  final int price;
  final String imageUrl;
  final String date;

  EventData({
    required this.eventId,
    required this.title,
    required this.category,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.date,
  });

  factory EventData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventData(
      eventId: doc.id,
      title: data['title'] ?? 'No Title',
      category: data['category'] ?? 'Event',
      location: data['location'] ?? 'Unknown',
      price: data['price'] ?? 0,
      imageUrl: data['imageUrl'] ?? 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14',
      date: data['date'] ?? '',
    );
  }
}

// ============================================================================
// SERVICES
// ============================================================================
class TicketService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get currentUserId => _auth.currentUser?.uid ?? '';

  static Stream<List<BookingData>> getBookingsByStatus(String status) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingData.fromFirestore(doc))
            .toList());
  }

  static Future<EventData?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventData.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching event: $e');
      return null;
    }
  }


}

// ============================================================================
// MAIN SCREEN
// ============================================================================
class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled'];
  final List<String> _statuses = ['pending', 'completed', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TicketTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 20),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TicketTheme.cardBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'My Tickets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TicketTheme.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TicketTheme.cardBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          return Expanded(
            child: _buildTabItem(_tabs[index], index),
          );
        }),
      ),
    );
  }

  Widget _buildTabItem(String text, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TicketTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : TicketTheme.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedTab == 0) {
      // Show upcoming events for booking
      return _buildUpcomingEvents();
    } else {
      // Show actual bookings for completed/cancelled
      return _buildBookingsList(_statuses[_selectedTab]);
    }
  }

  Widget _buildUpcomingEvents() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').limit(10).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: TicketTheme.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No upcoming events');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final event = EventData.fromFirestore(doc);
            return UpcomingTicketCard(
              event: event,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(eventData: doc),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBookingsList(String status) {
    return StreamBuilder<List<BookingData>>(
      stream: TicketService.getBookingsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: TicketTheme.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No tickets found');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final booking = snapshot.data![index];
            return BookedTicketCard(booking: booking);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: TicketTheme.textGrey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: TicketTheme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', false, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }),
            _buildNavItem(Icons.explore_outlined, 'Explore', false, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ExploreScreen()),
              );
            }),
            _buildNavItem(Icons.favorite_border, 'Favorite', false, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteScreen()),
              );
            }),
            _buildNavItem(Icons.confirmation_number_outlined, 'Tickets', true, () {}),
            _buildNavItem(Icons.person_outline, 'Profile', false, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? TicketTheme.primary : TicketTheme.textGrey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? TicketTheme.primary : TicketTheme.textGrey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TICKET CARDS
// ============================================================================

// Card for upcoming events (not booked yet)
class UpcomingTicketCard extends StatelessWidget {
  final EventData event;
  final VoidCallback onTap;

  const UpcomingTicketCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TicketTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                event.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[300],
                  child: const Icon(Icons.event, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBadge(category: event.category),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TicketTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: TicketTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: TicketTheme.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${event.price} /person',
                    style: const TextStyle(
                      color: TicketTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: TicketTheme.primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: TicketTheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Card for booked tickets (completed/cancelled)
class BookedTicketCard extends StatelessWidget {
  final BookingData booking;

  const BookedTicketCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventData?>(
      future: TicketService.getEventById(booking.eventId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                color: TicketTheme.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final event = snapshot.data!;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TicketTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Event Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      event.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.event, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CategoryBadge(category: event.category),
                            const Spacer(),
                            StatusBadge(status: booking.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: TicketTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: TicketTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: TicketTheme.textGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Ticket Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TicketTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTicketInfo(
                      Icons.confirmation_number_outlined,
                      booking.ticketType,
                    ),
                    _buildTicketInfo(
                      Icons.event_seat,
                      '${booking.seats} ${booking.seats > 1 ? 'Seats' : 'Seat'}',
                    ),
                    _buildTicketInfo(
                      Icons.payments_outlined,
                      '₹${booking.totalAmount}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Action Button
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: TicketTheme.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: TicketTheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'View E-Ticket',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: TicketTheme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: TicketTheme.textDark,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SMALL COMPONENTS
// ============================================================================
class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TicketTheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: TicketTheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return TicketTheme.success;
      case 'cancelled':
        return TicketTheme.error;
      case 'pending':
        return TicketTheme.warning;
      default:
        return TicketTheme.textGrey;
    }
  }

  String _getStatusText() {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}