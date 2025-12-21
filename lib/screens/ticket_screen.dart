import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_themes/app_theme.dart';
import 'home_screen.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  int selectedTab = 0;

  String get status {
    if (selectedTab == 0) return 'upcoming';
    if (selectedTab == 1) return 'completed';
    return 'cancelled';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.deepOrange,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    "Ticket",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
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
            const SizedBox(height: 6),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .where('status', isEqualTo: status)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];

                  if (selectedTab == 0 && docs.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      children: [
                        ticketCard(
                          category: "Music",
                          title: "Live Concert Night",
                          image:
                              "https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2",
                          location: "Delhi",
                          price: 799,
                        ),
                      ],
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tickets found",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index];
                      return ticketCard(
                        category: data['category'],
                        title: data['title'],
                        image: data['image'],
                        location: data['location'],
                        price: data['price'],
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
              color:
                  selectedTab == index ? Colors.deepOrange : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 32,
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

  Widget ticketCard({
    required String category,
    required String title,
    required String image,
    required String location,
    required int price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  image,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: const TextStyle(fontSize: 13),
                        ),
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
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Leave Review",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "E-Ticket",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
}
