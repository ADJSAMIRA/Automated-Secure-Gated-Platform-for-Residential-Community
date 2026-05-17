import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:residenceapp/screens/ResidentHomeScreen.dart';
import 'package:residenceapp/screens/SecurityHomePage.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
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
          
          // get notification the moment resident enter his profile
      
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
  print("Go to Maintenance Home Screen");
 // Navigator.pushReplacement(
  //  context, 
  //  MaterialPageRoute(
    //  builder: (context) => MaintenanceHomeScreen(
    //    userName: userName, 
      //  userId: userId
     // )
 //   )
 // );
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
  //else if (role == 'MaintenanceStaff') {
   // print(" Navigating to Maintenance Home");
    // إذا كنتِ قد أنشأتِ واجهة الصيانة، استدعيها هنا
  //  Navigator.pushReplacement(
   //   context, 
    //  MaterialPageRoute(builder: (context) => MaintenanceHomeScreen(userName: name, userId: id))
   // );
  //} 
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
                              onPressed: () {},
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