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
   
    int totalSpots = parkingSpots.length;
    int availableSpots = parkingSpots.where((spot) => spot['status'] != 'Occupied').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text(
          "Smart Parking", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
        ),
        backgroundColor: const Color(0xFF1D2A6B),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: parkingSpots.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1D2A6B)))
          : Column(
              children: [
              
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3A49F9), Color(0xFF1D2A6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D2A6B).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Find Your Spot",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "$availableSpots / $totalSpots Available Slots",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                   
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),

            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Parking Layout",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2A6B)),
                      ),
                      Row(
                        children: [
                          _buildLegendDot(Colors.green, "Free"),
                          const SizedBox(width: 12),
                          _buildLegendDot(Colors.red, "Full"),
                        ],
                      )
                    ],
                  ),
                ),

              
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: parkingSpots.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, 
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        var spot = parkingSpots[index];
                        bool isOccupied = spot['status'] == 'Occupied';
                        bool isAuto = spot['spot_name'] == 'P03'; 

                      //  Color statusColor = isOccupied ? const Color(0xFFE57373) : const Color(0xFF81C784);
                        Color accentColor = isOccupied ? const Color(0xFFD32F2F) : const Color(0xFF388E3C);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAuto ? const Color(0xFF3A49F9) : Colors.grey.shade200,
                              width: isAuto ? 2.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                  ),
                                ),
                              ),
                              
                             
                              Icon(
                                isOccupied ? Icons.directions_car_rounded : Icons.local_parking_rounded,
                                color: accentColor,
                                size: 30,
                              ),
                              
                              
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      spot['spot_name'],
                                      style: TextStyle(
                                        color: isAuto ? const Color(0xFF1D2A6B) : Colors.black, 
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (isAuto) ...[
                                      const SizedBox(width: 2),
                                      const Icon(Icons.bolt, color: Colors.amber, size: 14), 
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

 
  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color.withOpacity(0.7), shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}