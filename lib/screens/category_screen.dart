import 'package:flutter/material.dart';

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

            // --------- TOP BAR -----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  ),
                  Spacer(),
                  Text(
                    "Category",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --------- GRID -----------
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
            )
          ],
        ),
      ),
    );
  }
}

//---------------- CATEGORY ITEM WIDGET ----------------
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
    return Column(
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
    );
  }
}