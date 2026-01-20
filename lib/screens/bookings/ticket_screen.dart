import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../events/event_detail_screen.dart';
import '../home/home_screen.dart';
import '../home/explore_screen.dart';
import '../home/favorite_screen.dart';
import '../profile/profile_screen.dart';

// ============================================================================
// CONSTANTS & THEME
// ============================================================================
class TicketTheme {
  static const primary = Color(0xFFEA580C); // Deep orange
  static const primaryLight = Color(0xFFFFEDD5);
  static const background = Color(0xFFFAFAFA);
  static const cardBg = Colors.white;
  static const textDark = Color(0xFF1F2937);
  static const textGrey = Color(0xFF6B7280);
  static const textLightGrey = Color(0xFF9CA3AF);
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const border = Color(0xFFE5E7EB);
  static const shadow = Color(0x1A000000);
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
  final String? qrCodeUrl;
  final String? bookingReference;

  BookingData({
    required this.bookingId,
    required this.eventId,
    required this.ticketType,
    required this.seats,
    required this.totalAmount,
    required this.status,
    this.createdAt,
    this.qrCodeUrl,
    this.bookingReference,
  });

  factory BookingData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookingData(
      bookingId: doc.id,
      eventId: data['eventId']?.toString() ?? '',
      ticketType: data['ticketType']?.toString() ?? 'Regular',
      seats: (data['seats'] as int?) ?? 1,
      totalAmount: (data['totalAmount'] as int?) ?? 0,
      status: data['status']?.toString() ?? 'pending',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      qrCodeUrl: data['qrCodeUrl']?.toString(),
      bookingReference: data['bookingReference']?.toString(),
    );
  }

  String get formattedDate {
    if (createdAt == null) return 'Date not available';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt!);
  }
}

class EventData {
  final String eventId;
  final String title;
  final String category;
  final String location;
  final int price;
  final String imageUrl;
  final DateTime? date;
  final String? description;
  final String? organizer;

  EventData({
    required this.eventId,
    required this.title,
    required this.category,
    required this.location,
    required this.price,
    required this.imageUrl,
    this.date,
    this.description,
    this.organizer,
  });

  factory EventData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EventData(
      eventId: doc.id,
      title: data['title']?.toString() ?? 'Event Title',
      category: data['category']?.toString() ?? 'General',
      location: data['location']?.toString() ?? 'Location not specified',
      price: (data['price'] as int?) ?? 0,
      imageUrl: data['imageUrl']?.toString() ?? 
          'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=400&h=225&fit=crop',
      date: data['eventTime'] != null 
          ? (data['eventTime'] as Timestamp).toDate()
          : data['date'] != null 
              ? DateFormat('dd/MM/yyyy').parse(data['date'].toString())
              : null,
      description: data['description']?.toString(),
      organizer: data['organizer']?.toString(),
    );
  }

  String get formattedDate {
    if (date == null) return 'Date not available';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date!);
  }
}

// ============================================================================
// SERVICES
// ============================================================================
class TicketService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get currentUserId => _auth.currentUser?.uid ?? '';

  static bool get isUserLoggedIn => _auth.currentUser != null;

  static Stream<List<BookingData>> getBookingsByStatus(String status) {
    if (!isUserLoggedIn) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint('Error fetching bookings: $error');
          return const Stream.empty();
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingData.fromFirestore(doc))
            .toList());
  }

  static Future<EventData?> getEventById(String eventId) async {
    try {
      if (eventId.isEmpty) return null;
      
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

  static Stream<QuerySnapshot> getUpcomingEvents() {
    return _firestore
        .collection('events')
        .where('eventTime', isGreaterThan: Timestamp.now())
        .orderBy('eventTime', descending: false)
        .limit(10)
        .snapshots()
        .handleError((error) {
          debugPrint('Error fetching events: $error');
          return const Stream.empty();
        });
  }

  static Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      rethrow;
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
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  final List<String> _tabs = ['Upcoming', 'Booked', 'Completed', 'Cancelled'];
  final List<String> _statuses = ['upcoming', 'booked', 'completed', 'cancelled'];
  final List<IconData> _tabIcons = [
    Icons.upcoming_outlined,
    Icons.confirmation_number_outlined,
    Icons.check_circle_outline,
    Icons.cancel_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    if (!TicketService.isUserLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginRequiredDialog();
      });
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to view your tickets.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showCancelBookingDialog(String bookingId, String eventTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel your booking for "$eventTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelBooking(bookingId);
            },
            style: TextButton.styleFrom(
              foregroundColor: TicketTheme.error,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await TicketService.cancelBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking cancelled successfully'),
          backgroundColor: TicketTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to cancel booking'),
          backgroundColor: TicketTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: TicketTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tabs
            _buildTabs(),
            
            // Body Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: TicketTheme.primary,
                backgroundColor: TicketTheme.background,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 24,
                        vertical: 16,
                      ),
                      sliver: _buildContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: TicketTheme.cardBg,
        border: Border(
          bottom: BorderSide(color: TicketTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: TicketTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TicketTheme.primaryLight,
                border: Border.all(color: TicketTheme.primary.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: TicketTheme.primary,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tickets',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: TicketTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your event bookings',
                  style: TextStyle(
                    fontSize: 14,
                    color: TicketTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Row(
            children: [
              // Search Button
              GestureDetector(
                onTap: () {
                  // Implement search
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TicketTheme.background,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: TicketTheme.textGrey,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Filter Button
              GestureDetector(
                onTap: () {
                  // Show filter options
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TicketTheme.background,
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    size: 20,
                    color: TicketTheme.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TicketTheme.cardBg,
        border: Border(
          bottom: BorderSide(color: TicketTheme.border, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            return _buildTabItem(index);
          }),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final isSelected = _selectedTab == index;
    final isBookingTab = _tabs[index] != 'Upcoming';
    final bookingCount = isBookingTab ? 0 : null; // Would come from actual data
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? TicketTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _tabIcons[index],
              size: 18,
              color: isSelected ? Colors.white : TicketTheme.textGrey,
            ),
            const SizedBox(width: 8),
            Text(
              _tabs[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : TicketTheme.textGrey,
              ),
            ),
            if (bookingCount != null && bookingCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : TicketTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  bookingCount.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? TicketTheme.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!TicketService.isUserLoggedIn) {
      return _buildLoginRequired();
    }
    
    switch (_selectedTab) {
      case 0: // Upcoming Events
        return _buildUpcomingEvents();
      default: // Bookings
        return _buildBookingsList(_statuses[_selectedTab]);
    }
  }

  Widget _buildLoginRequired() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login_rounded,
              size: 80,
              color: TicketTheme.textLightGrey,
            ),
            const SizedBox(height: 20),
            Text(
              'Login Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: TicketTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please login to view and manage your tickets',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: TicketTheme.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TicketTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text('Login Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return StreamBuilder<QuerySnapshot>(
      stream: TicketService.getUpcomingEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingShimmer();
        }
        
        if (snapshot.hasError) {
          return _buildErrorState('Failed to load events');
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.upcoming_outlined,
            title: 'No Upcoming Events',
            subtitle: 'Check back later for new events',
          );
        }
        
        final events = snapshot.data!.docs;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final doc = events[index];
              final event = EventData.fromFirestore(doc);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UpcomingTicketCard(
                  event: event,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(eventData: doc),
                      ),
                    );
                  },
                ),
              );
            },
            childCount: events.length,
          ),
        );
      },
    );
  }

  Widget _buildBookingsList(String status) {
    return StreamBuilder<List<BookingData>>(
      stream: TicketService.getBookingsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingShimmer();
        }
        
        if (snapshot.hasError) {
          return _buildErrorState('Failed to load tickets');
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            icon: Icons.confirmation_number_outlined,
            title: 'No Tickets Found',
            subtitle: status == 'booked' 
                ? 'You don\'t have any active bookings'
                : 'No $status tickets in your history',
          );
        }
        
        final bookings = snapshot.data!;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final booking = bookings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BookedTicketCard(
                  booking: booking,
                  onCancel: _selectedTab == 1 // Only for booked tickets
                      ? () => _showCancelBookingDialog(booking.bookingId, 'Event')
                      : null,
                  onViewDetails: () {
                    // View ticket details
                  },
                ),
              );
            },
            childCount: bookings.length,
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 20,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 16,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: 5,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: TicketTheme.textLightGrey,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TicketTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: TicketTheme.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: TicketTheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Something Went Wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TicketTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: TicketTheme.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: TicketTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: TicketTheme.cardBg,
        border: Border(
          top: BorderSide(color: TicketTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: TicketTheme.shadow,
            blurRadius: 8,
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
            _buildNavItem(Icons.favorite_border, 'Favorites', false, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteScreen()),
              );
            }),
            _buildNavItem(Icons.confirmation_number, 'Tickets', true, () {}),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? TicketTheme.primaryLight : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? TicketTheme.primary : TicketTheme.textGrey,
            ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TicketTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TicketTheme.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: TicketTheme.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: TicketTheme.background,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: TicketTheme.primary,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: TicketTheme.background,
                      child: Center(
                        child: Icon(
                          Icons.event_rounded,
                          size: 32,
                          color: TicketTheme.textLightGrey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TicketTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: TicketTheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        '₹${event.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TicketTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Event Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TicketTheme.textDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location and Date
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: TicketTheme.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: TicketTheme.textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: TicketTheme.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: TicketTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Book Button
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TicketTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

class BookedTicketCard extends StatelessWidget {
  final BookingData booking;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;

  const BookedTicketCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventData?>(
      future: TicketService.getEventById(booking.eventId),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final event = snapshot.data;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TicketTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TicketTheme.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: TicketTheme.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loading/Error/Content
              if (isLoading) _buildLoadingContent(),
              if (hasError) _buildErrorContent(),
              if (!isLoading && !hasError && event != null) 
                _buildEventContent(event, context),
              
              // Ticket Details Section
              if (!isLoading && !hasError) ...[
                const SizedBox(height: 16),
                Divider(color: TicketTheme.border, height: 1),
                const SizedBox(height: 16),
                
                _buildTicketDetailsSection(),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                _buildActionButtons(context, event),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 100,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: TicketTheme.errorLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: TicketTheme.error,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Not Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TicketTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Could not load event details',
                style: TextStyle(
                  fontSize: 14,
                  color: TicketTheme.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventContent(EventData event, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: TicketTheme.background,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              event.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                    color: TicketTheme.primary,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: TicketTheme.background,
                  child: Center(
                    child: Icon(
                      Icons.event_rounded,
                      size: 32,
                      color: TicketTheme.textLightGrey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Event Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BookingStatusBadge(status: booking.status),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TicketTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TicketTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Event Title
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TicketTheme.textDark,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Location and Date
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: TicketTheme.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: TicketTheme.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: TicketTheme.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: TicketTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ticket Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TicketTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailItem(
              Icons.confirmation_number_outlined,
              'Ticket Type',
              booking.ticketType,
            ),
            _buildDetailItem(
              Icons.event_seat_rounded,
              'Seats',
              '${booking.seats} ${booking.seats > 1 ? 'Seats' : 'Seat'}',
            ),
            _buildDetailItem(
              Icons.payments_rounded,
              'Total Amount',
              '₹${booking.totalAmount}',
            ),
          ],
        ),
        if (booking.bookingReference != null) ...[
          const SizedBox(height: 12),
          _buildDetailItem(
            Icons.qr_code_rounded,
            'Booking Reference',
            booking.bookingReference!,
          ),
        ],
        if (booking.formattedDate.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDetailItem(
            Icons.access_time_rounded,
            'Booked On',
            booking.formattedDate,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: TicketTheme.textGrey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: TicketTheme.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TicketTheme.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, EventData? event) {
    final isCancelled = booking.status == 'cancelled';
    final isCompleted = booking.status == 'completed';
    
    return Row(
      children: [
        if (onCancel != null && !isCancelled && !isCompleted)
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: TicketTheme.error,
                side: BorderSide(color: TicketTheme.error),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel Booking'),
            ),
          ),
        if (onCancel != null && !isCancelled && !isCompleted)
          const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onViewDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: TicketTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              isCompleted ? 'View E-Ticket' : 'View Details',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SMALL COMPONENTS
// ============================================================================

class BookingStatusBadge extends StatelessWidget {
  final String status;

  const BookingStatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return TicketTheme.success;
      case 'cancelled':
        return TicketTheme.error;
      case 'booked':
      case 'pending':
        return TicketTheme.warning;
      default:
        return TicketTheme.textGrey;
    }
  }

  Color _getStatusBgColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return TicketTheme.successLight;
      case 'cancelled':
        return TicketTheme.errorLight;
      case 'booked':
      case 'pending':
        return TicketTheme.warningLight;
      default:
        return TicketTheme.background;
    }
  }

  String _getStatusText() {
    final text = status[0].toUpperCase() + status.substring(1);
    if (text == 'Booked') return 'Active';
    return text;
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'booked':
      case 'pending':
        return Icons.pending_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getStatusBgColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 12,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }
}