import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController tab;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "Help Center",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search",
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 45,
              child: TabBar(
                controller: tab,
                indicatorColor: Colors.deepOrange,
                labelColor: Colors.deepOrange,
                unselectedLabelColor: Colors.black54,
                tabs: const [
                  Tab(text: "FAQ"),
                  Tab(text: "Contact Us"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tab,
                children: [
                  faqSection(),
                  contactSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget faqSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildTabChips(),
        const SizedBox(height: 16),
        tile("Is my personal information secure?",
            "Yes, your data is encrypted and safely stored."),
        tile("Can I share event details with friends?",
            "You can easily share event details using social apps."),
        tile("How do I receive booking details?",
            "Booking details are sent via email and app notifications."),
        tile("How can I edit my profile information?",
            "Go to profile section and tap on edit profile."),
        tile("How does filter work?",
            "Filters help you find events by category and location."),
        tile("Is voice or video call available?",
            "Currently we support chat and email support."),
        tile("How do I access my tickets?",
            "Tickets are available in the Ticket section."),
      ],
    );
  }

  Widget contactSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        contactTileAsset(
          "assets/icons/whatsapp.png",
          "WhatsApp Support",
          "+91 98765 43210\n+91 91234 56789",
        ),
        contactTileAsset(
          "assets/icons/gmail.png",
          "Email Support",
          "support@example.com",
        ),
        contactTileAsset(
          "assets/icons/facebook.png",
          "Facebook",
          "facebook.com/example",
        ),
        contactTileAsset(
          "assets/icons/instagram.png",
          "Instagram",
          "@example",
        ),
        contactTileAsset(
          "assets/icons/telegram.png",
          "Telegram",
          "t.me/example",
        ),
        contactTileAsset(
          "assets/icons/google.png",
          "Website",
          "www.example.com",
        ),
      ],
    );
  }

  Widget tile(String title, String desc) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      iconColor: Colors.deepOrange,
      collapsedIconColor: Colors.deepOrange,
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      children: [
        Text(
          desc,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget contactTileAsset(String iconPath, String title, String subtitle) {
    return ExpansionTile(
      leading: Image.asset(iconPath, width: 26, height: 26),
      title: Text(title),
      iconColor: Colors.deepOrange,
      collapsedIconColor: Colors.deepOrange,
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 12),
      children: [
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget buildTabChips() {
    return Row(
      children: [
        chip("All", true),
        const SizedBox(width: 8),
        chip("Services", false),
        const SizedBox(width: 8),
        chip("General", false),
        const SizedBox(width: 8),
        chip("Account", false),
      ],
    );
  }

  Widget chip(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.deepOrange : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
