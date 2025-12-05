import 'package:flutter/material.dart';
import '../../custom_themes/app_theme.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';
import 'ticket_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final pages = [
    const HomeMainView(),
    const ExploreScreen(),
    const FavoriteScreen(),
    const TicketScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.colorAccent,
        unselectedItemColor: Colors.grey,
        elevation: 5,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorite"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: "Ticket"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeMainView extends StatelessWidget {
  const HomeMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            buildSearchBar(),
            const SizedBox(height: 20),
            buildHeader("Categories"),
            const SizedBox(height: 12),
            buildCategories(),
            const SizedBox(height: 20),
            buildHeader("Upcoming Events"),
            const SizedBox(height: 12),
            buildUpcomingEventCard(
              img: "https://images.pexels.com/photos/164712/pexels-photo-164712.jpeg",
              title: "Acoustic Serenade Showcase",
              price: 30,
            ),
            const SizedBox(height: 20),
            buildHeader("Nearby Events"),
            const SizedBox(height: 12),
            buildNearbyEventCard(),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              hintText: "Search Events, Organizer",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.colorAccent.withOpacity(.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.tune, color: AppTheme.colorAccent),
        )
      ],
    );
  }

  Widget buildHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          "See all",
          style: TextStyle(
            color: AppTheme.colorAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildCategories() {
    final items = [
      ["Gaming", Icons.sports_esports],
      ["Arts", Icons.color_lens],
      ["Business", Icons.work],
      ["Fashion", Icons.checkroom],
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((c) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.colorAccentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(c[1] as IconData, color: AppTheme.colorAccent),
            ),
            const SizedBox(height: 6),
            Text(c[0] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        );
      }).toList(),
    );
  }

  Widget buildUpcomingEventCard({
    required String img,
    required String title,
    required int price,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(img, height: 160, width: double.infinity, fit: BoxFit.cover),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Music", style: TextStyle(color: Colors.white)),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.favorite_border, color: Colors.red),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.location_on, size: 18, color: Colors.orange),
              SizedBox(width: 4),
              Text("New York, USA"),
              SizedBox(width: 10),
              Icon(Icons.calendar_month, size: 18, color: Colors.orange),
              SizedBox(width: 4),
              Text("May 29 - 10:00 PM"),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$30.00 /Person",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    const CircleAvatar(
                      radius: 14,
                      backgroundImage:
                          NetworkImage("https://randomuser.me/api/portraits/men/11.jpg"),
                    ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 18),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildNearbyEventCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "https://images.pexels.com/photos/2774556/pexels-photo-2774556.jpeg",
              width: 110,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Dance", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Modern Dance Fiesta",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.location_on, size: 18, color: Colors.orange),
                    SizedBox(width: 4),
                    Text("New York, USA")
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
