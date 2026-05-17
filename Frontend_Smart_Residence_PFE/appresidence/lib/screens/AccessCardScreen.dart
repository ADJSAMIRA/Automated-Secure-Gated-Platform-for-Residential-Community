//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AccessCardScreen extends StatelessWidget {
  final String fullName;
  final String apartmentNo;
  final String userId;

  const AccessCardScreen({
    super.key,
    required this.fullName,
    required this.apartmentNo,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
   
    final String qrData =  "https://adjsamira.github.io/smartgate-pfe/?id=$userId";

    return Scaffold(
      appBar: AppBar(title: const Text("My Digital Key"), backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.white, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SCAN AT GATE", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 20),
              QrImageView(data: qrData, size: 200),
              const Divider(height: 40),
              _rowInfo("Resident", fullName),
              _rowInfo("Apartment", apartmentNo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}