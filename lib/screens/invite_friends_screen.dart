import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen>
    with SingleTickerProviderStateMixin {
  final String inviteLink = "https://eventapp/invite/user123";

  late AnimationController controller;
  late Animation<double> fade;
  late Animation<Offset> slide;

  String get inviteMessage =>
      "Hey 👋\n\nI’m using EventApp to discover amazing events near me 🎉🎶\n\nJoin me using this link and don’t miss out:\n$inviteLink\n\nSee you at the next event! 🔥";

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeIn));
    slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
  }

  Future<void> openWhatsApp() async {
    final uri = Uri.parse(
        "whatsapp://send?text=${Uri.encodeComponent(inviteMessage)}");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openTelegram() async {
    final uri = Uri.parse(
        "tg://msg?text=${Uri.encodeComponent(inviteMessage)}");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openGmail() async {
    final uri = Uri.parse(
        "mailto:?subject=${Uri.encodeComponent("Join me on EventApp")}&body=${Uri.encodeComponent(inviteMessage)}");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openInstagram() async {
    final uri = Uri.parse(
        "https://www.instagram.com/");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Invite Friends",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Share your invite link",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: inviteLink));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          inviteLink,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.copy,
                          color: Colors.deepOrange, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              "Invite via social apps",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                socialAssetIcon(
                  asset: "assets/icons/whatsapp.png",
                  label: "WhatsApp",
                  onTap: openWhatsApp,
                ),
                socialAssetIcon(
                  asset: "assets/icons/gmail.png",
                  label: "Gmail",
                  onTap: openGmail,
                ),
                socialAssetIcon(
                  asset: "assets/icons/instagram.png",
                  label: "Instagram",
                  onTap: openInstagram,
                ),
                socialAssetIcon(
                  asset: "assets/icons/telegram.png",
                  label: "Telegram",
                  onTap: openTelegram,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget socialAssetIcon({
    required String asset,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
