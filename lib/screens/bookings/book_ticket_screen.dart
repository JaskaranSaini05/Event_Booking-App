import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking_model.dart';
import 'review_ticket_summary_screen.dart';

// ============================================================================
// CONSTANTS
// ============================================================================
class BookingConstants {
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 30.0;

  static const double spacingXS = 4.0;
  static const double spacingS = 6.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacing3XL = 32.0;
  static const double spacing4XL = 40.0;
}

class BookingColors {
  static const Color primary = Colors.deepOrange;
  static const Color accent = Color(0xFFFF6E40);
  static const Color background = Colors.white;
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
}

// ============================================================================
// MODELS
// ============================================================================
class UserBookingData {
  final String name;
  final String email;
  final String phone;

  UserBookingData({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory UserBookingData.empty() {
    return UserBookingData(
      name: '',
      email: '',
      phone: '',
    );
  }

  factory UserBookingData.fromFirestore(Map<String, dynamic> data) {
    return UserBookingData(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}

/// ✅ Event basic info (to add in booking)
class EventBookingData {
  final String title;
  final String location;
  final Timestamp eventTime;

  EventBookingData({
    required this.title,
    required this.location,
    required this.eventTime,
  });

  factory EventBookingData.empty() {
    return EventBookingData(
      title: '',
      location: '',
      eventTime: Timestamp.now(),
    );
  }

  factory EventBookingData.fromFirestore(Map<String, dynamic> data) {
    return EventBookingData(
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      eventTime:
          data['eventTime'] is Timestamp ? data['eventTime'] : Timestamp.now(),
    );
  }
}

// ============================================================================
// SERVICES
// ============================================================================
class BookingService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// ✅ Load user data from users collection
  static Future<UserBookingData> loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return UserBookingData.empty();

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return UserBookingData.empty();

      return UserBookingData.fromFirestore(doc.data() ?? {});
    } catch (e) {
      debugPrint('Error loading user data: $e');
      return UserBookingData.empty();
    }
  }

  /// ✅ Load event data from events collection
  static Future<EventBookingData> loadEventData(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) return EventBookingData.empty();

      return EventBookingData.fromFirestore(doc.data() ?? {});
    } catch (e) {
      debugPrint('Error loading event data: $e');
      return EventBookingData.empty();
    }
  }

  /// ✅ Create booking with user + event linking fields
  static Future<String> createBooking({
    required String eventId,
    required String ticketType,
    required int seats,
    required int price,
    required String name,
    required String email,
    required String phone,
    required String gender,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // ✅ load event details for eventTitle, eventDate, eventLocation
      final eventData = await loadEventData(eventId);

      final ref = _firestore.collection('bookings').doc();

      final booking = BookingModel(
        bookingId: ref.id,
        userId: user.uid,
        eventId: eventId,

        // ✅ new fields added
        eventTitle: eventData.title,
        eventDate: eventData.eventTime,
        eventLocation: eventData.location,

        ticketType: ticketType,
        seats: seats,
        price: price,
        totalAmount: price * seats,

        name: name,
        email: email,
        phone: phone,
        gender: gender,

        status: 'pending',
        createdAt: Timestamp.now(),
      );

      await ref.set(booking.toMap());
      return ref.id;
    } catch (e) {
      debugPrint('Error creating booking: $e');
      rethrow;
    }
  }
}

// ============================================================================
// VALIDATORS
// ============================================================================
class FormValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select gender';
    }
    return null;
  }
}

// ============================================================================
// MAIN SCREEN
// ============================================================================
class BookTicketScreen extends StatefulWidget {
  final String ticketType;
  final int seats;
  final int price;
  final String eventId;

  const BookTicketScreen({
    super.key,
    required this.ticketType,
    required this.seats,
    required this.price,
    required this.eventId,
  });

  @override
  State<BookTicketScreen> createState() => _BookTicketScreenState();
}

class _BookTicketScreenState extends State<BookTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGender = "Male";

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final userData = await BookingService.loadUserData();

    if (mounted) {
      setState(() {
        _nameController.text = userData.name;
        _emailController.text = userData.email;
        _phoneController.text = userData.phone;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await BookingService.createBooking(
        eventId: widget.eventId,
        ticketType: widget.ticketType,
        seats: widget.seats,
        price: widget.price,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewTicketSummaryScreen(
              eventId: widget.eventId,
              ticketData: {
                'ticketType': widget.ticketType,
                'seats': widget.seats,
                'price': widget.price,
                'totalAmount': widget.price * widget.seats,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: ${e.toString()}'),
            backgroundColor: BookingColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookingColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BookingColors.primary),
            )
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: BookingColors.background,
      elevation: 0,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: BookingColors.cardBackground,
          borderRadius: BorderRadius.circular(BookingConstants.radiusMedium),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: BookingColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        "Book Ticket",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: BookingColors.textPrimary,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BookingConstants.spacingXL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTicketSummaryCard(),
            const SizedBox(height: BookingConstants.spacing3XL),
            _buildSectionHeader(),
            const SizedBox(height: BookingConstants.spacingXL),
            _buildFormFields(),
            const SizedBox(height: BookingConstants.spacing4XL),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(BookingConstants.spacingXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            BookingColors.primary,
            BookingColors.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BookingConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: BookingColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ticket Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BookingConstants.spacingM,
                  vertical: BookingConstants.spacingS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(BookingConstants.radiusSmall),
                ),
                child: Text(
                  widget.ticketType.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BookingConstants.spacingXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Seats', '${widget.seats}', Icons.event_seat),
              _buildSummaryItem('Price', '₹${widget.price}', Icons.local_offer),
              _buildSummaryItem(
                'Total',
                '₹${widget.price * widget.seats}',
                Icons.payment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: BookingConstants.spacingS),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: BookingColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: BookingConstants.spacingM),
        const Text(
          "Your Information",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BookingColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomInputField(
          label: 'Full Name',
          controller: _nameController,
          icon: Icons.person_outline,
          validator: FormValidators.validateName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),
        CustomInputField(
          label: 'Email Address',
          controller: _emailController,
          icon: Icons.email_outlined,
          validator: FormValidators.validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        CustomInputField(
          label: 'Phone Number',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          validator: FormValidators.validatePhone,
          keyboardType: TextInputType.phone,
        ),

        // ✅ Gender Dropdown
        _buildGenderDropdown(),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: BookingConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gender",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: BookingColors.textPrimary,
            ),
          ),
          const SizedBox(height: BookingConstants.spacingS),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            items: const [
              DropdownMenuItem(value: "Male", child: Text("Male")),
              DropdownMenuItem(value: "Female", child: Text("Female")),
              DropdownMenuItem(value: "Other", child: Text("Other")),
            ],
            onChanged: (val) {
              if (val == null) return;
              setState(() => _selectedGender = val);
            },
            validator: FormValidators.validateGender,
            decoration: InputDecoration(
              filled: true,
              fillColor: BookingColors.inputBackground,
              prefixIcon: const Icon(
                Icons.people_outline,
                color: BookingColors.primary,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BookingConstants.radiusMedium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BookingConstants.radiusMedium),
                borderSide: BorderSide(
                  color: BookingColors.border.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BookingConstants.radiusMedium),
                borderSide: const BorderSide(
                  color: BookingColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: BookingColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BookingConstants.radiusXL),
          ),
          elevation: 4,
          shadowColor: BookingColors.primary.withOpacity(0.5),
        ),
        onPressed: _isSaving ? null : _handleContinue,
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: BookingConstants.spacingS),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM WIDGETS
// ============================================================================
class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool enabled;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BookingConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: BookingColors.textPrimary,
            ),
          ),
          const SizedBox(height: BookingConstants.spacingS),
          TextFormField(
            controller: controller,
            enabled: enabled,
            validator: validator,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              hintText: 'Enter your $label',
              hintStyle: const TextStyle(
                color: BookingColors.textHint,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: BookingColors.primary,
                size: 22,
              ),
              filled: true,
              fillColor: BookingColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BookingConstants.radiusMedium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BookingConstants.radiusMedium),
                borderSide: BorderSide(
                  color: BookingColors.border.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BookingConstants.radiusMedium),
                borderSide: const BorderSide(
                  color: BookingColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BookingConstants.radiusMedium),
                borderSide: const BorderSide(
                  color: BookingColors.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BookingConstants.radiusMedium),
                borderSide: const BorderSide(
                  color: BookingColors.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: BookingConstants.spacingL,
                vertical: BookingConstants.spacingL,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
