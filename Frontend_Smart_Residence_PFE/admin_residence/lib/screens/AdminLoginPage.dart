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
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    final TextEditingController answerController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    String securityQuestion = "";
    int currentStep = 1; 
    bool isDialogLoading = false;

    
    InputDecoration _buildInputDecoration(String hint, IconData icon) {
      return InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              Icon(
                currentStep == 3 ? Icons.lock_open : Icons.lock_reset, 
                color: const Color(0xFF1A237E)
              ),
              const SizedBox(width: 10),
              Text(
                currentStep == 3 ? "Set New Password" : "Reset Password", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                if (currentStep == 1) ...[
                  const Text("Enter your email address to get your security question:"),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration("Your Email Address", Icons.email_outlined),
                  ),
                ],
                
               
                if (currentStep == 2) ...[
                  const Text("Security Question:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Text(securityQuestion, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 15),
                  const Text("Your Answer:"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: answerController,
                    decoration: _buildInputDecoration("Type your security answer", Icons.question_answer_outlined),
                  ),
                ],

                
                if (currentStep == 3) ...[
                  const Text("Security Verified! ✅", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Enter your new secure password:"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true, 
                    decoration: _buildInputDecoration("New Password", Icons.vpn_key_outlined),
                  ),
                ],
                
                if (isDialogLoading) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDialogLoading ? null : () {
                if (currentStep > 1) {
                  setDialogState(() => currentStep--); 
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(currentStep == 1 ? "Cancel" : "Back", style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: isDialogLoading ? null : () async {
                
                
                if (currentStep == 1) {
                  if (resetEmailController.text.trim().isEmpty) {
                    Fluttertoast.showToast(msg: "Please enter your email", backgroundColor: Colors.orange);
                    return;
                  }
                  setDialogState(() => isDialogLoading = true);
                  try {
                    final res = await ApiService.getSecurityQuestion(resetEmailController.text.trim());
                    final data = jsonDecode(res.body);
                    
                    if (res.statusCode == 200 && data['security_question'] != null) {
                      setDialogState(() {
                        securityQuestion = data['security_question'];
                        currentStep = 2; 
                      });
                    } else {
                      Fluttertoast.showToast(msg: data['message'] ?? "Email not found", backgroundColor: Colors.red);
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Error fetching question.", backgroundColor: Colors.red);
                  } finally {
                    setDialogState(() => isDialogLoading = false);
                  }
                }
                
                
                else if (currentStep == 2) {
                  if (answerController.text.trim().isEmpty) {
                    Fluttertoast.showToast(msg: "Please answer the question", backgroundColor: Colors.orange);
                    return;
                  }
                  setDialogState(() => isDialogLoading = true);
                  try {
                  
                    final res = await ApiService.resetPasswordWithQuestion(
                      resetEmailController.text.trim(),
                      answerController.text.trim(), 
                      "ValidationCheck_Temp123",      
                    );
                    final data = jsonDecode(res.body);

                    if (res.statusCode == 200) {
                    
                      setDialogState(() {
                        currentStep = 3; 
                      });
                    } else {
                     
                      Fluttertoast.showToast(
                        msg: data['message'] ?? "Incorrect answer! Try again.", 
                        backgroundColor: Colors.red,
                        toastLength: Toast.LENGTH_LONG
                      );
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Verification error", backgroundColor: Colors.red);
                  } finally {
                    setDialogState(() => isDialogLoading = false);
                  }
                }
                
               
                else if (currentStep == 3) {
                  if (newPasswordController.text.isEmpty) {
                    Fluttertoast.showToast(msg: "Please enter your new password", backgroundColor: Colors.orange);
                    return;
                  }
                  setDialogState(() => isDialogLoading = true);
                  try {
                    final res = await ApiService.resetPasswordWithQuestion(
                      resetEmailController.text.trim(),
                      answerController.text.trim(), 
                      newPasswordController.text,
                    );

                    if (res.statusCode == 200) {
                      Fluttertoast.showToast(msg: "Password updated successfully! ", backgroundColor: Colors.green);
                      Navigator.pop(context);
                    } else {
                      final data = jsonDecode(res.body);
                      Fluttertoast.showToast(msg: data['message'] ?? "Error saving password", backgroundColor: Colors.red);
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Error saving password", backgroundColor: Colors.red);
                  } finally {
                    setDialogState(() => isDialogLoading = false);
                  }
                }
              },
              child: Text(
                currentStep == 3 ? "Save Password" : "Next",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
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
  onPressed: () => _showForgotPasswordDialog(context), 
  child: const Text("Forgot?", style: TextStyle(fontSize: 12, color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
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