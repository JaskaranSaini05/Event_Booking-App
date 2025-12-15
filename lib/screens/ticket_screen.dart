import 'package:flutter/material.dart';
import '../custom_themes/app_theme.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  int selectedTab = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Ticket",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  tabItem("Upcoming", 0),
                  const SizedBox(width: 24),
                  tabItem("Completed", 1),
                  const SizedBox(width: 24),
                  tabItem("Cancelled", 2),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  ticketCard(
                    category: "Workshop",
                    title: "CreativeCraft",
                    image:
                        "https://images.unsplash.com/photo-1521737604893-d14cc237f11d",
                  ),
                  ticketCard(
                    category: "Dance",
                    title: "Hip-Hop Heatwave",
                    image:
                        "https://images.unsplash.com/photo-1515165562835-c4c3a2b6f8c1",
                  ),
                  ticketCard(
                    category: "Arts",
                    title: "Artistic Odyssey",
                    image:
                        "https://images.unsplash.com/photo-1513364776144-60967b0f800f",
                  ),
                  ticketCard(
                    category: "Music",
                    title: "Live Jazz Night",
                    image:
                        "https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2",
                  ),
                  ticketCard(
                    category: "Tech",
                    title: "AI Future Summit",
                    image:
                        "https://images.unsplash.com/photo-1519389950473-47ba0277781c",
                  ),
                ],
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
              fontWeight: FontWeight.w600,
              color: selectedTab == index
                  ? Colors.deepOrange
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (selectedTab == index)
            Container(
              height: 3,
              width: 28,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
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
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            Colors.deepOrange.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(20),
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
                      children: const [
                        Icon(Icons.location_on,
                            size: 16,
                            color: Colors.deepOrange),
                        SizedBox(width: 4),
                        Text(
                          "New York, USA",
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "\$45.00 /person",
                      style: TextStyle(
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
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Leave Review",
                      style: TextStyle(
                          fontWeight: FontWeight.w500),
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
                    borderRadius:
                        BorderRadius.circular(30),
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
            ],
          ),
        ],
      ),
    );
  }
}
