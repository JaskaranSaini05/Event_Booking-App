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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              const Text(
                "Ticket",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  tabItem("Upcoming", 0),
                  const SizedBox(width: 20),
                  tabItem("Completed", 1),
                  const SizedBox(width: 20),
                  tabItem("Cancelled", 2),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
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
                  ],
                ),
              ),
            ],
          ),
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
              color:
                  selectedTab == index ? Colors.deepOrange : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (selectedTab == index)
            Container(
              height: 3,
              width: 25,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(5),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.location_on,
                            size: 16,
                            color: Colors.deepOrange),
                        SizedBox(width: 4),
                        Text("New York, USA",
                            style:
                                TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "\$45.00 /person",
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text("Leave Review"),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "E-Ticket",
                      style:
                          TextStyle(color: Colors.white),
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
