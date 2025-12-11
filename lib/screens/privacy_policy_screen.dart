import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Cancellation Policy",
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You can cancel your booking at any time before the event starts. "
              "Refunds will be processed based on the event organizer's rules. "
              "In case of late cancellations, a partial refund or no refund may apply. "
              "We aim to ensure a smooth and transparent cancellation experience. "
              "\n\nCancellation requests must be submitted through the official app. "
              "Processing time may vary depending on payment method and banking partners.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Terms & Conditions",
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "By using our platform, you agree to follow all rules set by event "
              "organizers and the application. Misuse of the platform, fraudulent "
              "activity, or violation of our guidelines may result in account restrictions. "
              "We reserve the right to update these terms at any time for improved service.\n\n"
              "Your access to certain features may be restricted based on your activity, "
              "location, or compliance with our policy. Failure to adhere to safety rules "
              "during events may result in immediate removal without refund.\n\n"
              "We encourage all users to review updates regularly to stay informed.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Privacy & Data Protection",
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We ensure that your personal information is collected, stored, and processed "
              "securely. Only essential details required for event bookings, notifications, "
              "and user identification are stored.\n\n"
              "We do not sell or share your data with third-party advertisers. However, "
              "certain information may be shared with event organizers to facilitate ticket "
              "management and entry verification.\n\n"
              "Your data is encrypted and handled according to international standards of "
              "privacy protection. You may request data deletion or modification anytime "
              "through customer support.\n\n"
              "In case of system updates or security enhancements, temporary service "
              "interruptions may occur. We always aim to restore services as quickly as possible.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "User Responsibilities",
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Users are responsible for maintaining the confidentiality of their login "
              "credentials. Any suspicious or unauthorized activity must be reported "
              "immediately.\n\n"
              "Refund fraud, fake identity use, or attempting to misuse promo codes may "
              "lead to account termination.\n\n"
              "We encourage users to use the platform responsibly and maintain a positive "
              "environment for all event attendees.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
