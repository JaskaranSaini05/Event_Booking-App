import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please read the details carefully.",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            _policyCard(
              title: "Cancellation Policy",
              text:
                  "You can cancel your booking before the event starts. Refunds depend on the organizer’s rules.\n\n"
                  "Late cancellations may result in partial or no refund.\n\n"
                  "Cancellation requests must be submitted through the app. Processing time may vary depending on your payment method.",
            ),

            const SizedBox(height: 14),

            _policyCard(
              title: "Terms & Conditions",
              text:
                  "By using this platform, you agree to follow all rules set by event organizers and the app.\n\n"
                  "Misuse, fraud, or violation of guidelines may lead to account restriction or termination.\n\n"
                  "We may update these terms anytime to improve service and user safety.",
            ),

            const SizedBox(height: 14),

            _policyCard(
              title: "Privacy & Data Protection",
              text:
                  "We collect only necessary information for bookings, notifications, and user identification.\n\n"
                  "We do not sell your data to third-party advertisers.\n\n"
                  "Some details may be shared with event organizers for ticket verification.\n\n"
                  "You can request data deletion or changes anytime through support.",
            ),

            const SizedBox(height: 14),

            _policyCard(
              title: "User Responsibilities",
              text:
                  "Keep your login details safe and private.\n\n"
                  "Report unauthorized activity immediately.\n\n"
                  "Fraud attempts, fake identities, or promo misuse may result in account termination.\n\n"
                  "Use the platform responsibly to maintain a positive environment for everyone.",
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ✅ Clean Card UI for sections
  static Widget _policyCard({required String title, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
