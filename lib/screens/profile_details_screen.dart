import 'package:flutter/material.dart';
import '../custom_themes/app_theme.dart';
import 'profile_screen.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.backgroundColor,
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4)
                            ],
                          ),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "Your Profile",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(
                          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  inputLabel("Name"),
                  inputField("Esther Howard"),
                  const SizedBox(height: 16),
                  inputLabel("Phone Number"),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      inputField("603.555.0123"),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          "Change",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  inputLabel("Email"),
                  inputField("example@gmail.com"),
                  const SizedBox(height: 16),
                  inputLabel("Gender"),
                  Container(
                    height: 52,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          "Select",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Spacer(),
                        Icon(Icons.keyboard_arrow_down,
                            color: Colors.deepOrange),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2))
                ],
              ),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget inputField(String hint) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        hint,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
