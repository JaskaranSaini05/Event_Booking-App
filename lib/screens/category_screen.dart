import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Category",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: 0.82,
                  mainAxisSpacing: 20,
                  children: const [
                    CategoryItem(icon: Icons.sports_esports, label: "Gaming"),
                    CategoryItem(icon: Icons.music_note, label: "Music"),
                    CategoryItem(icon: Icons.menu_book, label: "Book"),
                    CategoryItem(icon: Icons.language, label: "Language"),
                    CategoryItem(icon: Icons.photo_camera, label: "Photography"),
                    CategoryItem(icon: Icons.checkroom, label: "Fashion"),
                    CategoryItem(icon: Icons.eco, label: "Nature"),
                    CategoryItem(icon: Icons.fitness_center, label: "Fitness"),
                    CategoryItem(icon: Icons.pets, label: "Animal"),
                    CategoryItem(icon: Icons.brush, label: "Arts"),
                    CategoryItem(icon: Icons.sports_soccer, label: "Sports"),
                    CategoryItem(icon: Icons.attach_money, label: "Finance"),
                    CategoryItem(icon: Icons.science, label: "Technology"),
                    CategoryItem(icon: Icons.business_center, label: "Business"),
                    CategoryItem(icon: Icons.flight, label: "Travel"),
                    CategoryItem(icon: Icons.directions_car, label: "Cars"),
                    CategoryItem(icon: Icons.directions_run, label: "Dance"),
                    CategoryItem(icon: Icons.present_to_all, label: "Workshop"),
                    CategoryItem(icon: Icons.restaurant, label: "Food"),
                    CategoryItem(icon: Icons.agriculture, label: "Farming"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CategoryEventsScreen(category: label.toLowerCase()),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepOrange.withOpacity(0.15),
            ),
            child: Icon(icon, size: 30, color: Colors.deepOrange),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class CategoryEventsScreen extends StatelessWidget {
  final String category;

  const CategoryEventsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          category.toUpperCase(),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          if (events.isEmpty) {
            return const Center(child: Text("No events found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final data = events[index].data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EventDetailScreen(eventData: events[index]),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? '',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "₹${data['price']} / Person",
                        style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
