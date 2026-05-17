import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class ParkingScreen extends StatefulWidget {
  final String userId;
  const ParkingScreen({super.key, required this.userId});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  List<dynamic> parkingSpots = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchSpots();
    // Refresh every 3 seconds for real-time IoT updates (P03)
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchSpots();
    });
  }

  Future<void> _fetchSpots() async {
    final spots = await ApiService.getParkingSpots();
    if (mounted) {
      setState(() {
        parkingSpots = spots;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Smart Parking", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: parkingSpots.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: parkingSpots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 5 places par ligne
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  var spot = parkingSpots[index];
                  bool isOccupied = spot['status'] == 'Occupied';
                  bool isAuto = spot['spot_name'] == 'P03'; // spot qui on applique iot

                  return Container(
                    decoration: BoxDecoration(
                      color: isOccupied ? Colors.red[400] : Colors.green[400],
                      borderRadius: BorderRadius.circular(8),
                      border: isAuto ? Border.all(color: Colors.blueAccent, width: 2) : null,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isOccupied ? Icons.directions_car : Icons.local_parking,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          spot['spot_name'],
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}