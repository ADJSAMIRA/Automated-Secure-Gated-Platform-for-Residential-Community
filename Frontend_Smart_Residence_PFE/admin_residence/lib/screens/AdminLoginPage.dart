import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final contentType = response.headers['content-type'] ?? '';
      final isJson = contentType.contains('application/json');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
       //admin info
        final userMap = body['user'] ?? {};
        final userName = userMap['fullName'] ?? 'Admin';
        final userRole = userMap['role'] ?? '';
        
       
        final adminId = userMap['id']?.toString() ?? userMap['id_admin']?.toString() ?? '';

        if (userRole != 'Admin') {
          Fluttertoast.showToast(
              msg: "Access denied. Admins only! 🚫",
              backgroundColor: Colors.red);
          return;
        }

        Fluttertoast.showToast(
            msg: "Welcome $userName! ✅",
            backgroundColor: Colors.green);

        Navigator.pushReplacementNamed(
          context, 
          '/home',
          arguments: {
            'id': adminId,
            'username': userName,
          },
        );

      } else if (response.statusCode == 403) {
        if (isJson) {
          final body = jsonDecode(response.body);
          Fluttertoast.showToast(
              msg: body['message'] ?? "Account pending approval ⏳",
              backgroundColor: Colors.orange);
        }
      } else {
        String errorMsg = "Login failed";
        if (isJson) {
          final errorBody = jsonDecode(response.body);
          errorMsg = errorBody['message'] ?? errorMsg;
        }
        Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Connection error. Check server.",
          backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Log in",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E)),
          ),
          const SizedBox(height: 10),
          const Text(
            "Access your admin dashboard",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Email Field
          TextFormField(
            controller: _emailController,
            validator: (val) => val == null || val.isEmpty ? "Email is required" : null,
            decoration: _inputDecoration("Email", Icons.email_outlined),
          ),
          const SizedBox(height: 20),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            validator: (val) => val == null || val.isEmpty ? "Password is required" : null,
            decoration: _inputDecoration("Password", Icons.lock_outline),
          ),
          
          const SizedBox(height: 15),

          // Remember Me Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(value: false, onChanged: (val) {}),
                  ),
                  const SizedBox(width: 8),
                  const Text("Remember", style: TextStyle(fontSize: 12)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Forgot?", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          
          const SizedBox(height: 30),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: _handleLogin,
                    child: const Text("LOG IN",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 20),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}