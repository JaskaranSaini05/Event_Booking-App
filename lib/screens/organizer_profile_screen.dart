import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';
import 'ticket_screen.dart';
import 'profile_screen.dart';
import 'event_detail_screen.dart';

class OrganizerProfileScreen extends StatefulWidget {
  final String organizerId;

  const OrganizerProfileScreen({
    super.key,
    required this.organizerId,
  });

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool isFollowing = false;
  int navIndex = 0;
  DocumentSnapshot? organizerDoc;
  int followerCount = 0;
  int followingCount = 0;

  String get userId => FirebaseAuth.instance.currentUser!.uid;
  String get followDocId => "${userId}_${widget.organizerId}";

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchOrganizer();
    checkFollowing();
    fetchFollowStats();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> fetchOrganizer() async {
    final doc = await FirebaseFirestore.instance
        .collection('organizers')
        .doc(widget.organizerId)
        .get();

    if (mounted) {
      setState(() {
        organizerDoc = doc;
      });
    }
  }

  Future<void> checkFollowing() async {
    final doc = await FirebaseFirestore.instance
        .collection('following_organizers')
        .doc(followDocId)
        .get();

    if (mounted) {
      setState(() {
        isFollowing = doc.exists;
      });
    }
  }

  Future<void> fetchFollowStats() async {
    final followers = await FirebaseFirestore.instance
        .collection('following_organizers')
        .where('organizerId', isEqualTo: widget.organizerId)
        .get();

    final following = await FirebaseFirestore.instance
        .collection('following_organizers')
        .where('userId', isEqualTo: widget.organizerId)
        .get();

    if (mounted) {
      setState(() {
        followerCount = followers.docs.length;
        followingCount = following.docs.length;
      });
    }
  }

  Future<void> toggleFollow() async {
    final ref = FirebaseFirestore.instance
        .collection('following_organizers')
        .doc(followDocId);

    if (isFollowing) {
      await ref.delete();
      if (mounted) {
        setState(() {
          followerCount = followerCount > 0 ? followerCount - 1 : 0;
          isFollowing = false;
        });
      }
    } else {
      await ref.set({
        'userId': userId,
        'organizerId': widget.organizerId,
        'followedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() {
          followerCount++;
          isFollowing = true;
        });
      }
    }
  }

  void shareProfile(String name, String location) {
    Share.share(
      "Check out $name on EventApp 🎉\n\nThey host amazing events in $location.\n\nDiscover events and follow your favorite organizers!",
    );
  }

  void onNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ExploreScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const FavoriteScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const TicketScreen()));
    } else if (index == 4) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}m';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (organizerDoc == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    final data = organizerDoc!.data() as Map<String, dynamic>;
    final String name = data['name'] ?? 'Organizer';
    final String location = data['location'] ?? 'Location';
    final String about = data['about'] ?? '';
    final String address = data['address'] ?? '1012 Ocean avenue, New yourk, USA';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, name, location),
          _buildProfileInfo(name, location),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildEventsTab(),
                _buildReviewsTab(),
                _buildAboutTab(about, address),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String location) {
    return Stack(
      children: [
        // Background Image
        CachedNetworkImage(
          imageUrl: 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.grey),
          ),
          fadeInDuration: const Duration(milliseconds: 300),
        ),
        // Gradient Overlay
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Top Bar Actions
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Share & Favorite
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.black),
                        onPressed: () => shareProfile(name, location),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFollowing ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: toggleFollow,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(String name, String location) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Column(
        children: [
          // Profile Image
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1549213783-8284d0336c4f',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  width: 120,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  width: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                fadeInDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Follower & Following Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    formatCount(followerCount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Follower',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 80),
              Column(
                children: [
                  Text(
                    formatCount(followingCount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Following',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Organizer Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Follow Button
          GestureDetector(
            onTap: toggleFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: isFollowing ? Colors.deepOrange : Colors.transparent,
                border: Border.all(color: Colors.deepOrange, width: 1.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                isFollowing ? "FOLLOWING" : "FOLLOW",
                style: TextStyle(
                  color: isFollowing ? Colors.white : Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: TabBar(
              controller: tabController,
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepOrange,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: "Events"),
                Tab(text: "Reviews"),
                Tab(text: "About"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('organizerId', isEqualTo: widget.organizerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No events found",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildEventCard(docs[index]);
          },
        );
      },
    );
  }

  Widget _buildEventCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String eventId = doc.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(eventData: doc),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Favorite Icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: data['imageUrl'] ??
                        'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.deepOrange),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                    fadeInDuration: const Duration(milliseconds: 300),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('favorites')
                        .doc('${userId}_$eventId')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.hasData && snapshot.data!.exists;
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final docRef = FirebaseFirestore.instance
                                .collection('favorites')
                                .doc('${userId}_$eventId');

                            if (isFavorite) {
                              await docRef.delete();
                            } else {
                              await docRef.set({
                                'userId': userId,
                                'eventId': eventId,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['category'] ?? 'Music',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['title'] ?? 'Event Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data['location'] ?? 'New York, USA',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${data['price'] ?? '45.00'} /person',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('organizerId', isEqualTo: widget.organizerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No reviews yet",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.deepOrange[100],
                        child: Text(
                          (data['user'] ?? 'A')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['user'] ?? 'Anonymous',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (data['rating'] != null)
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < (data['rating'] ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['comment'] ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAboutTab(String about, String address) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Event Section
          const Text(
            'About Event',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            about.isEmpty
                ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua'
                : about,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.6,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          const Text(
            'Read more',
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          // Address Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Open map view
                },
                child: const Text(
                  'View on Map',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Map Placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl:
                  'https://maps.googleapis.com/maps/api/staticmap?center=$address&zoom=14&size=400x200&markers=color:red%7C$address&key=YOUR_API_KEY',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 150,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.map, size: 50, color: Colors.grey),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.map, size: 50, color: Colors.grey),
                ),
              ),
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: navIndex,
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      onTap: onNavTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: "Favorite",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_outlined),
          label: "Ticket",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }
}