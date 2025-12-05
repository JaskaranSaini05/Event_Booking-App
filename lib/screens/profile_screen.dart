import 'package:flutter/material.dart';
import '../../custom_themes/app_theme.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.colorTextColor),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
                const Expanded(
                  child: Text(
                    "Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.colorTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/150?img=12",
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.colorAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "Esther Howard",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.colorTextColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildTile(Icons.person, "Your profile"),
                  buildTile(Icons.credit_card, "Payment Methods"),
                  buildTile(Icons.group, "Following"),
                  buildTile(Icons.settings, "Settings"),
                  buildTile(Icons.help_outline, "Help Center"),
                  buildTile(Icons.lock_outline, "Privacy Policy"),
                  buildTile(Icons.people_alt_outlined, "Invites Friends"),
                  buildTile(Icons.logout, "Log out", iconColor: Colors.red),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTile(IconData icon, String title, {Color iconColor = AppTheme.colorAccent}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.colorTextColor,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.colorAccent,
          ),
          onTap: () {},
        ),
        Divider(color: AppTheme.lightGrey, height: 1),
      ],
    );
  }
}
