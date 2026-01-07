import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_card_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final int totalAmount;

  const PaymentMethodScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selected = "";

  Future<void> openGooglePay() async {
    final uri = Uri.parse(
      "upi://pay"
      "?pa=merchant@upi"
      "&pn=EventApp"
      "&am=${widget.totalAmount}"
      "&cu=INR"
      "&tn=Event Ticket Payment",
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void confirmPayment() {
    if (selected == "google") {
      openGooglePay();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment method selected: $selected"),
          backgroundColor: Colors.deepOrange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Payment Methods",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Credit & Debit Card",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: ListTile(
              leading: Image.asset(
                'assets/icons/atmcard.png',
                width: 32,
                height: 32,
              ),
              title: const Text("Add Card"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.deepOrange),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCardScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "More Payment Options",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                paymentOption(
                  title: "Paypal",
                  value: "paypal",
                  image: Image.asset('assets/icons/social.png', width: 30, height: 30),
                ),
                divider(),
                paymentOption(
                  title: "Apple Pay",
                  value: "apple",
                  image: Image.asset('assets/icons/applepay.png', width: 30, height: 30),
                ),
                divider(),
                paymentOption(
                  title: "Google Pay",
                  value: "google",
                  image: Image.asset('assets/icons/google.png', width: 30, height: 30),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selected.isNotEmpty ? confirmPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  disabledBackgroundColor: Colors.deepOrange.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Confirm Payment ₹${widget.totalAmount}",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentOption({
    required String title,
    Widget? image,
    required String value,
  }) {
    return ListTile(
      leading: image,
      title: Text(title),
      trailing: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: selected == value
            ? Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepOrange,
                ),
              )
            : null,
      ),
      onTap: () {
        setState(() {
          selected = value;
        });
      },
    );
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Divider(color: Colors.grey.shade300, height: 1),
    );
  }
}
