import 'package:flutter/material.dart';
import 'payment_method_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';
import 'ticket_screen.dart';
import 'profile_details_screen.dart';
import 'invite_friends_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorite"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: "Ticket"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: const [
                SizedBox(width: 48),
                Expanded(
                  child: Center(
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.bottomRight,
              children: const [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "https://upload.wikimedia.org/wikipedia/commons/5/5e/CheHighResLongHair.jpg",
                  ),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.deepOrange,
                  child: Icon(Icons.edit, color: Colors.white, size: 16),
                )
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Che Guevara",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  menuTile(Icons.person_outline, "Your Profile", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileDetailsScreen()),
                    );
                  }),
                  menuTile(Icons.credit_card, "Payment Methods", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
                    );
                  }),
                  menuTile(Icons.people_outline, "Following", () {}),
                  menuTile(Icons.settings_outlined, "Settings", () {}),
                  menuTile(Icons.help_outline, "Help Center", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                    );
                  }),
                  menuTile(Icons.privacy_tip_outlined, "Privacy Policy", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  }),
                  menuTile(Icons.group_add_outlined, "Invite Friends", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InviteFriendsScreen()),
                    );
                  }),
                  menuTile(Icons.logout, "Log Out", () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirm Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
