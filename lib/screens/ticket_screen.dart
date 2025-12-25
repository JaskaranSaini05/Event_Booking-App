import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_themes/app_theme.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';
import 'review_ticket_summary_screen.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  int selectedTab = 0;

  String get status {
    if (selectedTab == 0) return 'pending';
    if (selectedTab == 1) return 'completed';
    return 'cancelled';
  }

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
            navIcon(Icons.home, "Home", false, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            }),
            navIcon(Icons.explore, "Explore", false, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExploreScreen()));
            }),
            navIcon(Icons.favorite_border, "Favorite", false, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoriteScreen()));
            }),
            navIcon(Icons.confirmation_num_outlined, "Ticket", true, () {}),
            navIcon(Icons.person_outline, "Profile", false, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.deepOrange, width: 2),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.deepOrange),
                      ),
                    ),
                  ),
                  const Text(
                    "Ticket",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tabItem("Upcoming", 0),
                const SizedBox(width: 32),
                tabItem("Completed", 1),
                const SizedBox(width: 32),
                tabItem("Cancelled", 2),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('status', isEqualTo: status)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No tickets found", style: TextStyle(fontSize: 16)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return ticketCard(
                        docId: doc.id,
                        category: data['category'] ?? 'Music',
                        ticketType: data['ticketType'] ?? 'VIP',
                        title: data['eventTitle'] ?? 'Event Ticket',
                        location: data['location'] ?? 'Unknown',
                        price: (data['price'] as num?)?.toInt() ?? 0,
                        status: data['status'],
                        data: data,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabItem(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: selectedTab == index ? Colors.deepOrange : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 32,
            decoration: BoxDecoration(
              color: selectedTab == index ? Colors.deepOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget ticketCard({
    required String docId,
    required String category,
    required String ticketType,
    required String title,
    required String location,
    required int price,
    required String status,
    required Map<String, dynamic> data,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.image, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        badge(category),
                        const SizedBox(width: 6),
                        badge(ticketType),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.deepOrange),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₹$price /person",
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (status != 'cancelled')
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await FirebaseFirestore.instance
                          .collection('bookings')
                          .doc(docId)
                          .update({'status': 'cancelled'});

                      setState(() {
                        selectedTab = 2;
                      });
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewTicketSummaryScreen(ticketData: data),
                        ),
                      );
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "E-Ticket",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.deepOrange,
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.deepOrange : AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
