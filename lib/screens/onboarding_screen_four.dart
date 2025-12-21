import 'package:flutter/material.dart';
import 'onboarding_screen_three.dart';
import 'signup_page.dart';
import 'gender_selection_screen.dart';

class OnboardingScreenFour extends StatelessWidget {
  const OnboardingScreenFour({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/onboarding_screen_4.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: const [
                  Text(
                    "Engage in a Conversation with",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Event Organizers",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Chat directly with organizers, receive updates instantly, and stay informed about every event detail",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                indicator(false),
                const SizedBox(width: 8),
                indicator(false),
                const SizedBox(width: 8),
                indicator(true),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingScreenThree(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GenderSelectionScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget indicator(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? Colors.deepOrange
            : Colors.deepOrange.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}
