import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../home/home_screen.dart';
import '../home/explore_screen.dart';
import '../home/favorite_screen.dart';
import '../bookings/ticket_screen.dart';
import 'profile_screen.dart';
import '../events/event_detail_screen.dart';

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

  int navIndex = 4; // ✅ profile tab
  bool isFollowing = false;
  bool isLoading = true;
  bool hasError = false;
  bool followLoading = false;

  DocumentSnapshot? organizerDoc;

  int followerCount = 0;
  int followingCount = 0;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "";
  String get followDocId => "${userId}_${widget.organizerId}";

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    _initLoad();
  }

  Future<void> _initLoad() async {
    await fetchOrganizer();
    await checkFollowing();
    await fetchFollowStats();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> fetchOrganizer() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('organizers')
          .doc(widget.organizerId)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        setState(() {
          organizerDoc = null;
          hasError = true;
          isLoading = false;
        });
        return;
      }

      setState(() {
        organizerDoc = doc;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> checkFollowing() async {
    // ✅ Edge case: not logged in
    if (userId.isEmpty) {
      if (!mounted) return;
      setState(() => isFollowing = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('following_organizers')
          .doc(followDocId)
          .get();

      if (!mounted) return;
      setState(() => isFollowing = doc.exists);
    } catch (e) {
      // ignore silently
    }
  }

  Future<void> fetchFollowStats() async {
    try {
      // ✅ Followers = users who follow this organizer
      final followers = await FirebaseFirestore.instance
          .collection('following_organizers')
          .where('organizerId', isEqualTo: widget.organizerId)
          .get();

      // ✅ Following = organizers this organizer follows (optional feature)
      // NOTE: This works only if your organizer can follow others.
      // If not needed, you can remove this completely.
      final following = await FirebaseFirestore.instance
          .collection('following_organizers')
          .where('userId', isEqualTo: widget.organizerId)
          .get();

      if (!mounted) return;
      setState(() {
        followerCount = followers.docs.length;
        followingCount = following.docs.length;
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> toggleFollow() async {
    // ✅ Edge case: login required
    if (userId.isEmpty) {
      _showSnack("Please login to follow organizer");
      return;
    }

    // ✅ prevent spam clicks
    if (followLoading) return;

    setState(() => followLoading = true);

    try {
      final ref = FirebaseFirestore.instance
          .collection('following_organizers')
          .doc(followDocId);

      if (isFollowing) {
        await ref.delete();
        if (!mounted) return;
        setState(() {
          followerCount = followerCount > 0 ? followerCount - 1 : 0;
          isFollowing = false;
        });
      } else {
        await ref.set({
          'userId': userId,
          'organizerId': widget.organizerId,
          'followedAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        setState(() {
          followerCount++;
          isFollowing = true;
        });
      }
    } catch (e) {
      _showSnack("Something went wrong. Try again");
    } finally {
      if (mounted) setState(() => followLoading = false);
    }
  }

  void shareProfile(String name, String location) {
    Share.share(
      "Check out $name on EventApp 🎉\n\nThey host amazing events in $location.\n\nFollow and discover more events!",
    );
  }

  void onNavTap(int index) {
    if (index == navIndex) return;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              )
            : hasError || organizerDoc == null
                ? _errorUI()
                : RefreshIndicator(
                    onRefresh: () async {
                      await _initLoad();
                    },
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildProfileInfo(),
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              _buildEventsTab(),
                              _buildReviewsTab(),
                              _buildAboutTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ✅ HEADER
  Widget _buildHeader() {
    final data = organizerDoc!.data() as Map<String, dynamic>;
    final String name = (data['name'] ?? 'Organizer').toString();
    final String location = (data['location'] ?? 'Location').toString();

    final String headerImage = (data['coverImage'] ??
            'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3')
        .toString();

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: headerImage,
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
            color: Colors.grey[200],
            child: const Icon(Icons.image, color: Colors.grey),
          ),
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.45),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleBtn(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  _circleBtn(
                    icon: Icons.share,
                    onTap: () => shareProfile(name, location),
                  ),
                  const SizedBox(width: 10),
                  _circleBtn(
                    icon: isFollowing ? Icons.favorite : Icons.favorite_border,
                    iconColor: Colors.red,
                    onTap: toggleFollow,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onTap,
      ),
    );
  }

  // ✅ PROFILE INFO
  Widget _buildProfileInfo() {
    final data = organizerDoc!.data() as Map<String, dynamic>;
    final String name = (data['name'] ?? 'Organizer').toString();
    final String location = (data['location'] ?? 'Location').toString();

    final String profileImage = (data['profileImage'] ??
            'https://images.unsplash.com/photo-1549213783-8284d0336c4f')
        .toString();

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
                imageUrl: profileImage,
                height: 110,
                width: 110,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 110,
                  width: 110,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 110,
                  width: 110,
                  color: Colors.grey[300],
                  child:
                      const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // follower stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statBox(formatCount(followerCount), "Followers"),
              const SizedBox(width: 50),
              _statBox(formatCount(followingCount), "Following"),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black45),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Follow Button
          SizedBox(
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFollowing ? Colors.deepOrange : Colors.white,
                elevation: 0,
                side: const BorderSide(color: Colors.deepOrange, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: followLoading ? null : toggleFollow,
              child: followLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.deepOrange,
                      ),
                    )
                  : Text(
                      isFollowing ? "FOLLOWING" : "FOLLOW",
                      style: TextStyle(
                        color: isFollowing ? Colors.white : Colors.deepOrange,
                        fontWeight: FontWeight.w800,
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
                fontWeight: FontWeight.w700,
                fontSize: 14,
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

  Widget _statBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.black45, fontSize: 13),
        ),
      ],
    );
  }

  // ✅ EVENTS TAB
  Widget _buildEventsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('organizerId', isEqualTo: widget.organizerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Failed to load events",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

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

    final String imageUrl = (data['imageUrl'] ??
            'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4')
        .toString();

    final String category = (data['category'] ?? 'Event').toString();
    final String title = (data['title'] ?? 'Event Title').toString();
    final String location = (data['location'] ?? 'Location').toString();
    final dynamic priceRaw = data['price'];

    String priceText = "0";
    if (priceRaw != null) {
      priceText = priceRaw.toString();
    }

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
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 175,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 175,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Colors.deepOrange),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 175,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image,
                          size: 50, color: Colors.grey),
                    ),
                  ),
                ),

                // favorite
                Positioned(
                  top: 12,
                  right: 12,
                  child: userId.isEmpty
                      ? const SizedBox()
                      : StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('favorites')
                              .doc('${userId}_$eventId')
                              .snapshots(),
                          builder: (context, snapshot) {
                            final isFavorite =
                                snapshot.hasData && snapshot.data!.exists;

                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  try {
                                    final docRef = FirebaseFirestore.instance
                                        .collection('favorites')
                                        .doc('${userId}_$eventId');

                                    if (isFavorite) {
                                      await docRef.delete();
                                    } else {
                                      await docRef.set({
                                        'userId': userId,
                                        'eventId': eventId,
                                        'timestamp':
                                            FieldValue.serverTimestamp(),
                                      });
                                    }
                                  } catch (e) {
                                    _showSnack("Failed to update favorite");
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.black45),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$$priceText /person',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
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

  // ✅ REVIEWS TAB
  Widget _buildReviewsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('organizerId', isEqualTo: widget.organizerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Failed to load reviews",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

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

            final String userName = (data['user'] ?? 'Anonymous').toString();
            final String comment = (data['comment'] ?? '').toString();
            final int rating = (data['rating'] ?? 0) is int
                ? data['rating']
                : int.tryParse(data['rating'].toString()) ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.deepOrange.withOpacity(0.15),
                        child: Text(
                          userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : "A",
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < rating
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
                    comment.isEmpty ? "No comment" : comment,
                    style: const TextStyle(
                      color: Colors.black54,
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

  // ✅ ABOUT TAB
  Widget _buildAboutTab() {
    final data = organizerDoc!.data() as Map<String, dynamic>;
    final String about = (data['about'] ?? '').toString();
    final String address =
        (data['address'] ?? 'Address not provided').toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Organizer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            about.isEmpty
                ? "No description added by organizer."
                : about,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.6,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 18, color: Colors.black45),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 48, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ BOTTOM NAV
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

  // ✅ ERROR UI
  Widget _errorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              "Organizer not found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please check your internet and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchOrganizer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Retry",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
