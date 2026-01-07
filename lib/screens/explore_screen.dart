import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../custom_themes/app_theme.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'ticket_screen.dart';
import 'profile_screen.dart';
import 'event_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  final LatLng userLocation = const LatLng(40.7128, -74.0060);
  String searchQuery = '';

  final Map<String, LatLng> cityCoordinates = {
    'noida': const LatLng(28.5355, 77.3910),
    'delhi': const LatLng(28.7041, 77.1025),
    'mumbai': const LatLng(19.0760, 72.8777),
    'bangalore': const LatLng(12.9716, 77.5946),
    'pune': const LatLng(18.5204, 73.8567),
    'hyderabad': const LatLng(17.3850, 78.4867),
    'chennai': const LatLng(13.0827, 80.2707),
    'kolkata': const LatLng(22.5726, 88.3639),
    'jaipur': const LatLng(26.9124, 75.7873),
    'ahmedabad': const LatLng(23.0225, 72.5714),
    'lucknow': const LatLng(26.8467, 80.9462),
    'chandigarh': const LatLng(30.7333, 76.7794),
    'gurgaon': const LatLng(28.4595, 77.0266),
    'gurugram': const LatLng(28.4595, 77.0266),
    'ludhiana': const LatLng(30.9010, 75.8573),
    'new york': const LatLng(40.7128, -74.0060),
    'london': const LatLng(51.5074, -0.1278),
  };

  LatLng? getCoordinatesForLocation(String location) {
    final locationLower = location.toLowerCase().trim();
    for (var entry in cityCoordinates.entries) {
      if (locationLower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  double distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  List<QueryDocumentSnapshot> filterEvents(List<QueryDocumentSnapshot> docs) {
    if (searchQuery.isEmpty) return docs;
    
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString().toLowerCase();
      final location = (data['location'] ?? '').toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      
      return title.contains(query) || location.contains(query);
    }).toList();
  }

  List<Marker> buildMarkers(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'] ?? '';
      final coords = getCoordinatesForLocation(location);

      if (coords == null) return const Marker(point: LatLng(0, 0), width: 0, height: 0, child: SizedBox());

      final km = distanceKm(userLocation.latitude, userLocation.longitude, coords.latitude, coords.longitude);

      return Marker(
        point: coords,
        width: 70,
        height: 90,
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(eventData: doc)));
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)],
                  image: DecorationImage(
                    image: NetworkImage(data['imageUrl'] ?? 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                ),
                child: Text('${km.toStringAsFixed(1)} Km',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWeb = screenWidth > 600;
    final bottomNavHeight = isWeb ? 0.0 : 70.0;
    final mapHeight = screenHeight * (isWeb ? 0.55 : 0.50);
    final cardSectionHeight = screenHeight - mapHeight - bottomNavHeight - MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allEvents = snapshot.data!.docs;
          final filteredEvents = filterEvents(allEvents);

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                SizedBox(
                  height: mapHeight,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(initialCenter: userLocation, initialZoom: 13, minZoom: 3, maxZoom: 18),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.jaskaran.event_booking_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: userLocation,
                                width: 50,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                                  ),
                                  child: const Icon(Icons.my_location, color: Colors.white, size: 24),
                                ),
                              ),
                              ...buildMarkers(filteredEvents),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        right: 80,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search by title or location',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value.trim();
                                    });
                                  },
                                ),
                              ),
                              if (searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    setState(() {
                                      searchQuery = '';
                                    });
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 16,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 75,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                            ),
                            child: Text(
                              '${filteredEvents.length} events found',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  height: cardSectionHeight,
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No events found',
                                style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with different keywords',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final data = filteredEvents[index].data() as Map<String, dynamic>;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EventDetailScreen(eventData: filteredEvents[index])),
                                );
                              },
                              child: eventCard(
                                data['imageUrl'] ?? 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800',
                                data['category'] ?? 'General',
                                data['title'] ?? 'No Title',
                                data['location'] ?? 'Location TBD',
                                data['date'] ?? 'Date TBD',
                                (data['price'] as num?)?.toDouble() ?? 0.0,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: isWeb
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  navIcon(Icons.home_outlined, "Home", false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  }),
                  navIcon(Icons.explore, "Explore", true, () {}),
                  navIcon(Icons.favorite_border, "Favorite", false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoriteScreen()));
                  }),
                  navIcon(Icons.confirmation_number_outlined, "Ticket", false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TicketScreen()));
                  }),
                  navIcon(Icons.person_outline, "Profile", false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                ],
              ),
            ),
    );
  }

  Widget navIcon(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.deepOrange : Colors.grey),
          Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.deepOrange : Colors.grey)),
        ],
      ),
    );
  }

  Widget eventCard(String imageUrl, String category, String title, String location, String dateTime, double price) {
    final isHighlighted = searchQuery.isNotEmpty &&
        (title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            location.toLowerCase().contains(searchQuery.toLowerCase()));

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted ? Border.all(color: Colors.deepOrange, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isHighlighted ? Colors.deepOrange.withOpacity(0.3) : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20)),
                  child: Text(category,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.deepOrange)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, color: Colors.deepOrange, size: 20),
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
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: searchQuery.isNotEmpty && title.toLowerCase().contains(searchQuery.toLowerCase())
                        ? Colors.deepOrange
                        : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: searchQuery.isNotEmpty && location.toLowerCase().contains(searchQuery.toLowerCase())
                          ? Colors.deepOrange
                          : Colors.deepOrange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 13,
                          color: searchQuery.isNotEmpty && location.toLowerCase().contains(searchQuery.toLowerCase())
                              ? Colors.deepOrange
                              : Colors.black54,
                          fontWeight: searchQuery.isNotEmpty && location.toLowerCase().contains(searchQuery.toLowerCase())
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.deepOrange),
                    const SizedBox(width: 4),
                    Text(dateTime, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    const Text(' /Person', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                                image: NetworkImage('https://i.pravatar.cc/150?img=1'), fit: BoxFit.cover),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-8, 0),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: const DecorationImage(
                                  image: NetworkImage('https://i.pravatar.cc/150?img=2'), fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-16, 0),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: const DecorationImage(
                                  image: NetworkImage('https://i.pravatar.cc/150?img=3'), fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-24, 0),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                                child: Text('+',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}