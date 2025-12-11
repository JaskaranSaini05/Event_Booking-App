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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
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
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Expanded(
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
            Container(
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
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        tile("Is there share event details with friends?",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        tile("How do I receive Booking Details?",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        tile("How can I edit my profile information?",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        tile("How Filter Work?",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        tile("Is Voice call or Video Call Feature there?",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        tile("How do I access my purchased tickets?",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
      ],
    );
  }

  Widget contactSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        contactTile(Icons.headset_mic, "Customer Service", "support@email.com"),
        contactTile(Icons.chat, "WhatsApp", "(480) 555-0103"),
        contactTile(Icons.public, "Website", "www.example.com"),
        contactTile(Icons.thumb_up, "Facebook", "@example"),
        contactTile(Icons.alternate_email, "Twitter", "@example"),
        contactTile(Icons.camera_alt, "Instagram", "@example"),
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

  Widget contactTile(IconData icon, String title, String subtitle) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.deepOrange),
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
