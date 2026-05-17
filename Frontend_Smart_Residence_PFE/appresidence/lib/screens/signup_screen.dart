import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import '../widgets/custom_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController securityAnswerController = TextEditingController();

  String? selectedRole;
  String? selectedQuestion;
  bool isLoading = false;

  final List<String> roles = ['Resident', 'SecurityStaff', 'MaintenanceStaff'];
  final List<String> security_questions = [
    'What is your childhood nickname ?',
    'What was your first pet\'s name?',
    'What is a memorable place from your childhood?',
    'What is your favorite teacher\'s name?'
  ];

  Future<void> handleSignUp() async {
   //all data they need
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty|| 
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedRole == null ||
        selectedQuestion == null ||
        securityAnswerController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please fill all required fields",
          backgroundColor: Colors.orange);
      return;
    }

    //only nbrapartemt for resident
    if (selectedRole == 'Resident' && apartmentController.text.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Apartment number is required for residents",
          backgroundColor: Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
     
      String aptNo = (selectedRole == 'Resident') ? apartmentController.text.trim() : "";

      final response = await ApiService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        phoneController.text.trim(),
        aptNo,
        passwordController.text,
        role: selectedRole,
        securityQuestion: selectedQuestion,
        securityAnswer: securityAnswerController.text.trim(),
      );

      final contentType = response.headers['content-type'] ?? '';
      final isJson = contentType.contains('application/json');

      if (response.statusCode == 201 || response.statusCode == 200) {
        String msg = "Account Created Successfully! ✅";
        if (isJson) {
          final body = jsonDecode(response.body);
          if (body['status'] == 'pending') {
            msg = "Account Created! Waiting for admin approval ⏳";
          }
        }
        Fluttertoast.showToast(msg: msg, backgroundColor: Colors.green);
        Navigator.pop(context);
      } else {
        String errorMsg = "Registration failed";
        if (isJson) {
          final errorBody = jsonDecode(response.body);
          errorMsg = errorBody['message'] ?? errorBody['error'] ?? errorMsg;
        }
        Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
      }
    } catch (e) {
      print(" Error: $e");
      Fluttertoast.showToast(
          msg: "Error connecting to server",
          backgroundColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }
Widget buildDropdownField({
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: const Color(0xFF0D47A1), size: 20),
              const SizedBox(width: 10),
              Text(hint, style: const TextStyle(color: Color(0xFF0D47A1))),
            ],
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0D47A1)),
          items: items.map((String item) {
            return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.black87)));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/images/residence_view.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withOpacity(0.2),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text("JOIN US",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0)),
                  const Text("Create your smart residence account",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 15)
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomInputField(
                              controller: nameController,
                              hint: "Full Name",
                              icon: Icons.person_outline,
                              textColor: const Color(0xFF0D47A1)),
                          const SizedBox(height: 12),
                          CustomInputField(
                              controller: emailController,
                              hint: "Email Address",
                              icon: Icons.email_outlined,
                              textColor: const Color(0xFF0D47A1)),
                          const SizedBox(height: 12),
                          CustomInputField(
                              controller: phoneController,
                              hint: "Phone Number",
                              icon: Icons.phone_android,
textColor: const Color(0xFF0D47A1)),
                          const SizedBox(height: 12),

                          buildDropdownField(
                            hint: "Who are you?",
                            items: roles,
                            value: selectedRole,
                            icon: Icons.badge_outlined,
                            onChanged: (val) => setState(() => selectedRole = val),
                          ),
                          const SizedBox(height: 12),

                          //only resident
                          if (selectedRole == 'Resident') ...[
                            CustomInputField(
                                controller: apartmentController,
                                hint: "Apartment No.",
                                icon: Icons.home_work_outlined,
                                textColor: const Color(0xFF0D47A1)),
                            const SizedBox(height: 12),
                          ],

                          CustomInputField(
                              controller: passwordController,
                              hint: "Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                              textColor: const Color(0xFF0D47A1)),
                          const SizedBox(height: 12),

                          buildDropdownField(
                            hint: "Select Security Question",
                            items: security_questions,
                            value: selectedQuestion,
                            icon: Icons.security,
                            onChanged: (val) => setState(() => selectedQuestion = val),
                          ),
                          const SizedBox(height: 12),

                          CustomInputField(
                              controller: securityAnswerController,
                              hint: "Your Answer",
                              icon: Icons.question_answer_outlined,
                              textColor: const Color(0xFF0D47A1)),
                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A237E),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30)),
                                    ),
                                    onPressed: handleSignUp,
                                    child: const Text("REGISTER",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Already have an account? Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}