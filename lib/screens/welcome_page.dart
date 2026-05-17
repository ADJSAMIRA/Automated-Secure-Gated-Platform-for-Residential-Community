import 'package:flutter/material.dart';
import 'package:adminspace/screens/AdminSignupPage.dart'; 
import 'package:adminspace/screens/AdminLoginPage.dart'; 

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA), 
              Color(0xFFB8C6DB), 
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                width: 850,
                height: 550,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    children: [
                    
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutBack,
                        left: isLogin ? 0 : 425,
                        child: Container(
                          width: 425,
                          height: 550,
                          padding: const EdgeInsets.all(40),
                          child: isLogin ? const AdminLoginPage() : const AdminSignupPage(),
                        ),
                      ),

                     
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutBack,
                        left: isLogin ? 425 : 0,
                        child: Container(
                          width: 425,
                          height: 550,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                            ),
                          ),
                          child: _buildOverlayContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Welcome Back!" : "Hello, Admin!",
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 30, 
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Access the secure residence management portal to monitor and control the platform.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 40),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 2),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
          ),
          onPressed: () => setState(() => isLogin = !isLogin),
          child: Text(
            isLogin ? "CREATE ACCOUNT" : "SIGN IN", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}