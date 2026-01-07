import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'book_ticket_screen.dart';
import 'organizer_profile_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot eventData;
  const EventDetailScreen({super.key, required this.eventData});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isFavorite = false;
  bool readMore = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final doc = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(widget.eventData.id)
        .get();
    setState(() => isFavorite = doc.exists);
  }

  Future<void> toggleFavorite(Map<String, dynamic> data) async {
    final ref = FirebaseFirestore.instance
        .collection('favorites')
        .doc(widget.eventData.id);

    if (isFavorite) {
      await ref.delete();
    } else {
      await ref.set(data);
    }
    setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.eventData.data() as Map<String, dynamic>;

    final String title = data['title'] ?? '';
    final String category = data['category'] ?? '';
    final String location = data['location'] ?? '';
    final String date = data['date'] ?? '';
    final String description = data['description'] ?? '';
    final String organizer = data['organizer'] ?? '';
    final String? imageUrl = data['imageUrl'];
    final String? organizerId = data['organizerId'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        imageUrl ??
                            'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.share, color: Colors.black),
                                onPressed: () {
                                  Share.share('$title\n$location\n$date');
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () => toggleFavorite(data),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.deepOrange),
                      const SizedBox(width: 6),
                      Text(location,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 20),
                      const Icon(Icons.access_time,
                          size: 18, color: Colors.deepOrange),
                      const SizedBox(width: 6),
                      Text(date,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About Event',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    maxLines: readMore ? null : 5,
                    overflow:
                        readMore ? TextOverflow.visible : TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.grey, height: 1.6),
                  ),
                  if (description.length > 250)
                    GestureDetector(
                      onTap: () => setState(() => readMore = !readMore),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          readMore ? 'Read less' : 'Read more',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Organizer',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      if (organizerId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrganizerProfileScreen(
                                organizerId: organizerId),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/150?img=5'),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              organizer,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Text(
                              'Organize Team',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                builder: (_) => ChooseTicketBottomSheet(
                  eventId: widget.eventData.id,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class ChooseTicketBottomSheet extends StatefulWidget {
  final String eventId;
  const ChooseTicketBottomSheet({super.key, required this.eventId});

  @override
  State<ChooseTicketBottomSheet> createState() =>
      _ChooseTicketBottomSheetState();
}

class _ChooseTicketBottomSheetState
    extends State<ChooseTicketBottomSheet> {
  String selectedType = '';
  int selectedPrice = 0;
  int seats = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Center(
            child: Text(
              'Choose Ticket',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .doc(widget.eventId)
                  .collection('tickets')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final tickets = snapshot.data!.docs;

                return Row(
                  children: tickets.map((doc) {
                    final type = doc['type'];
                    final price = doc['price'];
                    final active = selectedType == type;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = type;
                            selectedPrice = price;
                            seats = 1;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: active ? Colors.deepOrange.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: active
                                  ? Colors.deepOrange
                                  : Colors.grey.shade300,
                              width: active ? 2.5 : 2,
                            ),
                            boxShadow: active ? [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ] : [],
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20),
                                child: AnimatedScale(
                                  scale: active ? 1.1 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.confirmation_number,
                                    size: 32,
                                    color: active
                                        ? Colors.deepOrange
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              Text(
                                type,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: active ? Colors.deepOrange : Colors.black,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.deepOrange
                                      : Colors.grey.shade200,
                                  borderRadius:
                                      const BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(16),
                                    bottomRight:
                                        Radius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  '₹$price /Person',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Number of Seats',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed:
                          seats > 1 ? () => setState(() => seats--) : null,
                      icon: Icon(
                        Icons.remove,
                        color: seats > 1 ? Colors.black : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      seats.toString(),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => setState(() => seats++),
                      icon: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: selectedType.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookTicketScreen(
                            eventId: widget.eventId,
                            ticketType: selectedType,
                            seats: seats,
                            price: selectedPrice,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                disabledBackgroundColor:
                    Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: selectedType.isEmpty ? 0 : 2,
              ),
              child: const Text(
                'Continue',
                style:
                    TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}