import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_screen_four.dart';
import 'age_selection.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String selectedGender = '';

  Future<void> saveGender() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedGender.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'gender': selectedGender}, SetOptions(merge: true));
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
                builder: (_) => const OnboardingScreenFour(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Tell us about yourself!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'To Enhance Your Experience, Please Share Your Gender',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = 'Male';
                });
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: selectedGender == 'Male'
                    ? Colors.deepOrange
                    : Colors.grey.shade200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.male, size: 40, color: Colors.white),
                    SizedBox(height: 6),
                    Text('Male', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = 'Female';
                });
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: selectedGender == 'Female'
                    ? Colors.deepOrange
                    : Colors.grey.shade200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.female, size: 40, color: Colors.white),
                    SizedBox(height: 6),
                    Text('Female', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedGender.isEmpty
                    ? null
                    : () async {
                        await saveGender();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AgeSelectionScreen(),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
