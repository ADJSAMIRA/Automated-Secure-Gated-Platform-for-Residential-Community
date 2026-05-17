import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';

class AdminSignupPage extends StatefulWidget {
  const AdminSignupPage({super.key});

  @override
  State<AdminSignupPage> createState() => _AdminSignupPageState();
}

class _AdminSignupPageState extends State<AdminSignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  String? selectedQuestion;
  bool isLoading = false;

  final List<String> securityQuestions = [
    'What was your childhood nickname?',
    'What was your first pet\'s name?',
    'What is a memorable place from your childhood?',
    'What is your favorite teacher\'s name?'
  ];

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedQuestion == null) {
      Fluttertoast.showToast(
          msg: "Please select a security question",
          backgroundColor: Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        '', 
        _passController.text,
        role: 'Admin',
        securityQuestion: selectedQuestion,
        securityAnswer: _answerController.text.trim(),
      );

     
      if (response.statusCode == 201 || response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Account Created Successfully! ✅", 
            backgroundColor: Colors.green);
        
        
        _formKey.currentState!.reset();
        setState(() => selectedQuestion = null);
      } else {
        final errorBody = jsonDecode(response.body);
        String errorMsg = errorBody['message'] ?? errorBody['error'] ?? "Registration failed";
        Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
      }
    } catch (e) {
      print("Error during signup: $e");
      Fluttertoast.showToast(msg: "Connection error", backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Account",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 5),
            const Text("Register as a new administrator", 
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),

            _buildTextField(_nameController, "Full Name", Icons.person),
            const SizedBox(height: 15),

            _buildTextField(_phoneController, "Phone Number", Icons.phone, isPhone: true),
            const SizedBox(height: 15),

            _buildTextField(_emailController, "Email Address", Icons.email_outlined),
            const SizedBox(height: 15),

            _buildTextField(_passController, "Password", Icons.lock_outline, isPass: true),
            const SizedBox(height: 15),

          
            _buildDropdownField(
              hint: "Select Security Question",
              value: selectedQuestion,
              icon: Icons.security,
              items: securityQuestions,
              onChanged: (val) => setState(() => selectedQuestion = val),
            ),
            const SizedBox(height: 15),

            _buildTextField(_answerController, "Your Answer", Icons.question_answer_outlined),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _handleSignup,
                      child: const Text("SIGN UP",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPass = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      validator: (val) => val == null || val.isEmpty ? "$hint is required" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 20),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint, 
    required String? value, 
    required IconData icon, 
    required List<String> items, 
    required Function(String?) onChanged
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null, 
          hint: Row(
            children: [
              Icon(icon, color: const Color(0xFF1A237E), size: 20),
              const SizedBox(width: 10),
              Text(hint, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A237E)),
          items: items.map((String item) => DropdownMenuItem(
            value: item, 
            child: Row( 
              children: [
                Icon(icon, color: const Color(0xFF1A237E), size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
              ],
            )
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}