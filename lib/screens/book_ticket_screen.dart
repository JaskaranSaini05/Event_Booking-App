import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'review_ticket_summary_screen.dart';

class BookTicketScreen extends StatefulWidget {
  final String ticketType;
  final int seats;

  const BookTicketScreen({
    super.key,
    required this.ticketType,
    required this.seats,
  });

  @override
  State<BookTicketScreen> createState() => _BookTicketScreenState();
}

class _BookTicketScreenState extends State<BookTicketScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedGender;
  String? selectedCountry;

  final List<String> countries = [
    "Argentina",
    "Australia",
    "Austria",
    "Belgium",
    "Brazil",
    "Canada",
    "China",
    "Denmark",
    "Finland",
    "France",
    "Germany",
    "India",
    "Indonesia",
    "Ireland",
    "Italy",
    "Japan",
    "Malaysia",
    "Mexico",
    "Netherlands",
    "New Zealand",
    "Norway",
    "Pakistan",
    "Philippines",
    "Poland",
    "Portugal",
    "Russia",
    "Saudi Arabia",
    "Singapore",
    "South Africa",
    "South Korea",
    "Spain",
    "Sri Lanka",
    "Sweden",
    "Switzerland",
    "Thailand",
    "Turkey",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
    "Vietnam"
  ];

  Future<void> saveBooking() async {
    final user = FirebaseAuth.instance.currentUser!;
    final bookingRef = FirebaseFirestore.instance.collection('bookings').doc();

    await bookingRef.set({
      'bookingId': bookingRef.id,
      'userId': user.uid,
      'ticketType': widget.ticketType,
      'seats': widget.seats,
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'gender': selectedGender,
      'country': selectedCountry,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    nameController.text = user?.displayName ?? '';
    emailController.text = user?.email ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Book Ticket",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Your Information Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            field("Name", nameController),
            field("Email", emailController),
            dropdown(
              "Gender",
              ["Male", "Female"],
              selectedGender,
              (val) => setState(() => selectedGender = val),
            ),
            field("Phone Number", phoneController),
            dropdown(
              "Country",
              countries,
              selectedCountry,
              (val) => setState(() => selectedCountry = val),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await saveBooking();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewTicketSummaryScreen(
                        ticketData: {
                          'ticketType': widget.ticketType,
                          'seats': widget.seats,
                        },
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: label == "Phone Number"
                ? TextInputType.phone
                : TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dropdown(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
