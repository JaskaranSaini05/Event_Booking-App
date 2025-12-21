import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gender_selection_screen.dart';
import 'signup_page.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  int selectedAge = 36;

  Future<void> saveAge() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'age': selectedAge}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const GenderSelectionScreen(),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            '2/3',
            style:
                TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'How Old Are You?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us to find age specific event',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              itemExtent: 60,
              diameterRatio: 1.4,
              perspective: 0.005,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedAge = index + 18;
                });
              },
              controller: FixedExtentScrollController(
                initialItem: selectedAge - 18,
              ),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 83,
                builder: (context, index) {
                  final age = index + 18;
                  final isSelected = age == selectedAge;
                  return Center(
                    child: Text(
                      age.toString(),
                      style: TextStyle(
                        fontSize: isSelected ? 40 : 22,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.deepOrange
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await saveAge();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
