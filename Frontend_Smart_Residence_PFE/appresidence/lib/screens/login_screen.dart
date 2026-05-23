import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart'; 
import 'package:residenceapp/screens/ResidentHomeScreen.dart';
import 'package:residenceapp/screens/SecurityHomePage.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'MaintenanceHomeScreen.dart';
import 'package:residenceapp/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields", backgroundColor: Colors.orange);
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await ApiService.login(emailController.text.trim(), passwordController.text);
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        final userName = body['user']['fullName'] ?? 'User';
        final userRole = body['user']['role'] ?? '';
        final token = body['token'] ?? '';
        final apartmentNo = body['user']['apartmentNumber']?.toString() ?? 'N/A';
        final userId = body['user']['id']?.toString() ?? '';
        
        final jobType = body['user']['job_type']; 

        Fluttertoast.showToast(
            msg: "Welcome $userName! ✅", 
            backgroundColor: Colors.green);
        
        if (mounted) {
          // maintenance staff didnt pick a job type yet
          if (userRole == 'MaintenanceStaff' && (jobType == null || jobType.isEmpty)) {
            setState(() => isLoading = false); 
            _showJobTypeDialog(context, userId, userName); 
          } 
          //a nrml resident pass to their page
          else if (userRole == 'Resident') {
            ResidentApp.of(context)?.setGlobalUser(userId);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResidentHomeScreen(
                  userName: userName,
                  apartmentNo: apartmentNo,
                  userId: userId,
                ),
              ),
            );
          }
          // maintence staff login deja choose his job type
          else if (userRole == 'MaintenanceStaff') {
      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MaintenanceHomeScreen(
      staffId: int.parse(userId), 
    ),
  ),
);
}
          //security staff login his interface
          else if (userRole == 'SecurityStaff') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SecurityHomeScreen(
                  userName: userName,
                  userId: userId,
                ),
              ),
            );
          }
        }

        print(" Token: $token");
        print(" Role: $userRole");
      } 
      else {
        Fluttertoast.showToast(msg: "Login failed. Check credentials", backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection error", backgroundColor: Colors.red);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showJobTypeDialog(BuildContext context, String userId, String userName) {
    String? selectedJob;
    
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Hello $userName", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose your Job Type to continuer:"),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                hint: const Text("Choose your job"),
                items: ['Plumbing', 'Electrical', 'Fireman'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setDialogState(() => selectedJob = val),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: selectedJob == null ? null : () async {
                bool success = await ApiService.updateJobType(userId, selectedJob!);
                
                if (success) {
                  Fluttertoast.showToast(
                    msg: "Perfect! Your specialty has been set to $selectedJob ✅",
                    backgroundColor: Colors.green,
                  );

                  if (mounted) {
                    ResidentApp.of(context)?.setGlobalUser(userId);
                    Navigator.pop(context); 
                    _navigateToCorrectHome('MaintenanceStaff', userName, 'N/A', userId);
                  }
                } else {
                  Fluttertoast.showToast(
                    msg: "Opps! Something went wrong. Please try again.",
                    backgroundColor: Colors.red,
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCorrectHome(String role, String name, String apt, String id) {
    print(" Navigating function started for role: $role");

    if (role == 'Resident') {
      print(" Navigating to Resident Home");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResidentHomeScreen(
            userName: name,
            apartmentNo: apt,
            userId: id,
          ),
        ),
      );
    } 
    else if (role == 'SecurityStaff') {
      print(" Navigating to Security Home");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SecurityHomeScreen(userName: name, userId: id)),
      );
    } else {
      print(" Unknown role detected: $role");
    }
  }

 
 void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    final TextEditingController answerController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    String securityQuestion = "";
    int currentStep = 1; 
    bool isDialogLoading = false;

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
                  CustomInputField(
                    controller: resetEmailController,
                    hint: "Your Email Address",
                    icon: Icons.email_outlined,
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
                  CustomInputField(
                    controller: answerController,
                    hint: "Type your security answer",
                    icon: Icons.question_answer_outlined,
                  ),
                ],

               
                if (currentStep == 3) ...[
                  const Text("Security Verified! ✅", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Enter your new secure password:"),
                  const SizedBox(height: 8),
                  CustomInputField(
                    controller: newPasswordController,
                    hint: "New Password",
                    icon: Icons.vpn_key_outlined,
                    isPassword: true,
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
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
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
                    Fluttertoast.showToast(msg: "Error fetching question. Check server connection!", backgroundColor: Colors.red);
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

                    if (res.statusCode == 200 && data['success'] == true) {
                     
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
                    final data = jsonDecode(res.body);

                    if (res.statusCode == 200 && data['success'] == true) {
                      Fluttertoast.showToast(msg: "Password updated successfully! ", backgroundColor: Colors.green);
                      Navigator.pop(context); 
                    } else {
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
                currentStep == 1 ? "Next" : (currentStep == 2 ? "Verify Answer" : "Save Password"),
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
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Photo Background
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/images/residence_view.jpg',
              fit: BoxFit.cover, 
            ),
          ),

          // 2. Blur Effect
          ClipRect( 
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "WELCOME",
                    style: TextStyle(
                      fontSize: 35, 
                      fontWeight: FontWeight.bold, 
                      color: Color.fromARGB(255, 26, 35, 126),
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(color: Colors.white70, blurRadius: 10, offset: Offset(0, 2))
                      ],
                    ),
                  ),
                  const Text(
                    "To your smart resident portal", 
                    style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)
                  ),
                  
                  const SizedBox(height: 60), 

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 5)
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomInputField(
                            controller: emailController, 
                            hint: "Email Address", 
                            icon: Icons.email_outlined,
                            textColor: const Color(0xFF1B5E20),
                          ),
                          const SizedBox(height: 20),
                          CustomInputField(
                            controller: passwordController, 
                            hint: "Password", 
                            icon: Icons.lock_outline, 
                            isPassword: true,
                            textColor: const Color(0xFF1B5E20),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(context), 
                              child: const Text("Forgot password?", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(height: 25),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: isLoading 
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 26, 35, 126), 
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    elevation: 10,
                                  ),
                                  onPressed: handleLogin,
                                  child: const Text(
                                    "Sign In", 
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: const Text(
                      "Don't have an account? Sign Up", 
                      style: TextStyle(color: Color.fromARGB(255, 1, 0, 0), fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 18, color: Color.fromARGB(255, 1, 0, 0)),
                        SizedBox(width: 5),
                        Text("Back to Home", style: TextStyle(color: Color.fromARGB(255, 1, 0, 0))),
                      ],
                    ),
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

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final Color textColor;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300), 
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 26, 35, 126)), 
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}