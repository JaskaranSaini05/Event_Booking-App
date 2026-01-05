import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_themes/app_theme.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';
import 'ticket_screen.dart';
import 'profile_screen.dart';
import 'category_screen.dart';
import 'event_detail_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            navIcon(Icons.home, "Home", true, () {}),
            navIcon(Icons.explore, "Explore", false, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreScreen()));
            }),
            navIcon(Icons.favorite_border, "Favorite", false, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteScreen()));
            }),
            navIcon(Icons.confirmation_num_outlined, "Ticket", false, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketScreen()));
            }),
            navIcon(Icons.person_outline, "Profile", false, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Row(
                children: [
                  Text("Location", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Icon(Icons.notifications_none, color: AppTheme.textPrimary),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppTheme.textPrimary),
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
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search Events, Organizer",
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.deepOrange),
                        ),
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              sectionHeader("Categories", context),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  categoryIcon(Icons.music_note, "Music"),
                  categoryIcon(Icons.palette, "Arts"),
                  categoryIcon(Icons.work_outline, "Business"),
                  categoryIcon(Icons.checkroom, "Fashion"),
                ],
              ),
              const SizedBox(height: 25),
              sectionHeader("Upcoming Events", context),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('events').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final events = snapshot.data!.docs;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 15),
                      itemBuilder: (context, index) {
                        final data = events[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(eventData: events[index]),
                              ),
                            );
                          },
                          child: eventCard(
                            data['title'] ?? '',
                            data['category'] ?? '',
                            data['location'] ?? '',
                            data['date'] ?? '',
                            (data['price'] as num?)?.toInt() ?? 0,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              sectionHeader("Nearby Events", context),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('events').limit(1).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }
                  final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(eventData: snapshot.data!.docs.first),
                        ),
                      );
                    },
                    child: eventSmallCard(
                      data['title'] ?? '',
                      data['category'] ?? '',
                      data['location'] ?? '',
                      data['date'] ?? '',
                    ),
                  );
                },
              ),
            ],
          ),
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
          Icon(icon, color: active ? Colors.deepOrange : AppTheme.textSecondary),
          Text(label, style: TextStyle(color: active ? Colors.deepOrange : AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget sectionHeader(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen()));
          },
          child: const Text("See all", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget categoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.deepOrange, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
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
      width: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Icon(Icons.image, size: 40, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          Text(category, style: const TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 2),
          Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            "₹$price /Person",
            style: const TextStyle(fontSize: 14, color: Colors.deepOrange, fontWeight: FontWeight.bold),
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
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 70,
            decoration: BoxDecoration(color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.image, color: Colors.white, size: 30)),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category, style: const TextStyle(color: Colors.deepOrange, fontSize: 12)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
