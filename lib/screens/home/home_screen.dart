import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../custom_themes/app_theme.dart';
import '../../models/event_model.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';
import '../bookings/ticket_screen.dart';
import '../profile/profile_screen.dart';
import '../events/category_screen.dart';
import '../events/event_detail_screen.dart';
import '../notification_screen.dart';
import 'search_screen.dart';
import 'upcoming_events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String getFormattedDateTime(Map<String, dynamic> data) {
    if (data['eventTime'] != null) {
      final dateTime = (data['eventTime'] as Timestamp).toDate();
      final dateFormat = DateFormat('MMM d, yyyy');
      final timeFormat = DateFormat('h:mm a');
      return '${dateFormat.format(dateTime)} • ${timeFormat.format(dateTime)}';
    }
    final date = data['date'] ?? '';
    return date.isNotEmpty ? date : 'Date TBD';
  }

  String getShortDate(Map<String, dynamic> data) {
    if (data['eventTime'] != null) {
      final dateTime = (data['eventTime'] as Timestamp).toDate();
      final dateFormat = DateFormat('MMM d');
      return dateFormat.format(dateTime);
    }
    final date = data['date'] ?? '';
    return date.isNotEmpty ? date : 'Date TBD';
  }

  void _performSearch() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchScreen(searchQuery: searchText),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      bottomNavigationBar: isMobile
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    navIcon(Icons.home, "Home", true, () {}),
                    navIcon(Icons.explore, "Explore", false, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ExploreScreen()));
                    }),
                    navIcon(Icons.favorite_border, "Favorite", false, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FavoriteScreen()));
                    }),
                    navIcon(Icons.confirmation_num_outlined, "Ticket", false,
                        () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => TicketScreen()));
                    }),
                    navIcon(Icons.person_outline, "Profile", false, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen()));
                    }),
                  ],
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (isWeb)
              Container(
                width: 250,
                color: AppTheme.backgroundColor,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    navIconVertical(Icons.home, "Home", true, () {}),
                    navIconVertical(Icons.explore, "Explore", false, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ExploreScreen()));
                    }),
                    navIconVertical(Icons.favorite_border, "Favorite", false,
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FavoriteScreen()));
                    }),
                    navIconVertical(
                        Icons.confirmation_num_outlined, "Ticket", false, () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => TicketScreen()));
                    }),
                    navIconVertical(Icons.person_outline, "Profile", false, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen()));
                    }),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Text("Location",
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const NotificationScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4)
                              ],
                            ),
                            child: Icon(Icons.notifications_none,
                                color: AppTheme.textPrimary),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.deepOrange),
                        const SizedBox(width: 4),
                        Text(
                          "New York, USA",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            color: AppTheme.textPrimary),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4)
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: "Search Events, Organizer",
                                hintStyle:
                                    TextStyle(color: AppTheme.textSecondary),
                                border: InputBorder.none,
                                icon: const Icon(Icons.search,
                                    color: Colors.deepOrange),
                              ),
                              style: TextStyle(color: AppTheme.textPrimary),
                              onSubmitted: (_) => _performSearch(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _performSearch,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.tune, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    sectionHeader("Categories", context, showSeeAll: true,
                        onSeeAllTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CategoryScreen()));
                    }),
                    const SizedBox(height: 10),
                    isWeb
                        ? Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              categoryIcon(Icons.music_note, "Music"),
                              categoryIcon(Icons.palette, "Arts"),
                              categoryIcon(Icons.work_outline, "Business"),
                              categoryIcon(Icons.checkroom, "Fashion"),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              categoryIcon(Icons.music_note, "Music"),
                              categoryIcon(Icons.palette, "Arts"),
                              categoryIcon(Icons.work_outline, "Business"),
                              categoryIcon(Icons.checkroom, "Fashion"),
                            ],
                          ),
                    const SizedBox(height: 25),
                    sectionHeader("Upcoming Events", context,
                        showSeeAll: true, onSeeAllTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UpcomingEventsScreen()));
                    }),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('events')
                            .orderBy('eventTime', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.deepOrange,
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No upcoming events',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final events = snapshot.data!.docs;
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 4),
                            itemCount: events.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 15),
                            itemBuilder: (context, index) {
                              final data =
                                  events[index].data() as Map<String, dynamic>;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(
                                          eventData: events[index]),
                                    ),
                                  );
                                },
                                child: eventCard(
                                  data['title'] ?? 'Untitled Event',
                                  data['category'] ?? 'General',
                                  data['location'] ?? 'Location TBD',
                                  getShortDate(data),
                                  data['price'] ?? 0,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    sectionHeader("Nearby Events", context, showSeeAll: false),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('events')
                          .limit(5)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Colors.deepOrange,
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No nearby events found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(
                                          eventData: doc),
                                    ),
                                  );
                                },
                                child: eventSmallCard(
                                  data['title'] ?? 'Untitled Event',
                                  data['category'] ?? 'General',
                                  data['location'] ?? 'Location TBD',
                                  getShortDate(data),
                                  data['price'] ?? 0,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget navIcon(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: active ? Colors.deepOrange : AppTheme.textSecondary,
              size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: active ? Colors.deepOrange : AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget navIconVertical(
      IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: active
              ? Colors.deepOrange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: active ? Colors.deepOrange : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: active ? Colors.deepOrange : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(String text, BuildContext context,
      {bool showSeeAll = true, VoidCallback? onSeeAllTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAllTap,
            child: const Text("See all",
                style: TextStyle(
                    color: Colors.deepOrange, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget categoryIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.15),
              shape: BoxShape.circle),
          child: Icon(icon, color: Colors.deepOrange, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget eventCard(
    String title,
    String category,
    String location,
    String date,
    int price,
  ) {
    return Container(
      width: 220,
  
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: Image.network(
                'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppTheme.lightGrey,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.lightGrey,
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          date,
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '₹$price',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget eventSmallCard(
    String title,
    String category,
    String location,
    String date,
    int price,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 75,
                height: 75,
                child: Image.network(
                  'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppTheme.lightGrey,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepOrange,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.lightGrey,
                      child: const Center(
                        child: Icon(Icons.image, size: 30, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            height: 1.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 10, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 10, color: Colors.grey),
                              const SizedBox(width: 3),
                              Text(
                                date,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            '₹$price',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
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