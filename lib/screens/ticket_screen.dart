import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';
import 'review_ticket_summary_screen.dart';
import 'leave_review_screen.dart';

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
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: bottomBar(context),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            header(context),
            const SizedBox(height: 24),
            tabs(),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('status', isEqualTo: status)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: Colors.deepOrange));
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return emptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;

                      return ticketCard(context, data);
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

  Widget header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Colors.black87),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Ticket",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget tabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        tabItem("Upcoming", 0),
        const SizedBox(width: 40),
        tabItem("Completed", 1),
        const SizedBox(width: 40),
        tabItem("Cancelled", 2),
      ],
    );
  }

  Widget tabItem(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = index);
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selectedTab == index
                  ? Colors.deepOrange
                  : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: selectedTab == index
                  ? Colors.deepOrange
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget ticketCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(
                        data['imageUrl'] ??
                            'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    badge(data['category'] ?? 'Event'),
                    const SizedBox(height: 8),
                    Text(
                      data['title'] ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.deepOrange),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data['location'] ?? '',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₹${data['price']} /person",
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: status == 'completed'
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LeaveReviewScreen(eventData: data),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border:
                          Border.all(color: Colors.deepOrange, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        "Leave Review",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange),
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
                        builder: (_) =>
                            ReviewTicketSummaryScreen(ticketData: data),
                      ),
                    );
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        "E-Ticket",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
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
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No tickets found",
              style:
                  TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget bottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          navIcon(Icons.home_outlined, "Home", false,
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HomeScreen()))),
          navIcon(Icons.explore_outlined, "Explore", false,
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ExploreScreen()))),
          navIcon(Icons.favorite_border, "Favorite", false,
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FavoriteScreen()))),
          navIcon(Icons.confirmation_number_outlined, "Ticket", true, () {}),
          navIcon(Icons.person_outline, "Profile", false,
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfileScreen()))),
        ],
      ),
    );
  }

  Widget navIcon(
      IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: active ? Colors.deepOrange : Colors.grey.shade600,
              size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                color:
                    active ? Colors.deepOrange : Colors.grey.shade600,
                fontSize: 12,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
