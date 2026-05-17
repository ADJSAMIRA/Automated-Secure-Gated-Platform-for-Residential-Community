import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //link 
  static const String baseUrl = "https://amazing-demographic-cardiovascular-louis.trycloudflare.com";

  static const Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // REGISTER
  static Future<http.Response> register(
    String fullName,
    String email,
    String phoneNumber,
    String apartmentNumber,
    String password, {
    String? role,
    String? securityQuestion,
    String? securityAnswer,
  }) async {
    final Map<String, dynamic> body = {
      "fullName": fullName,
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber,
      "role": role ?? 'Resident',
      "security_question": securityQuestion ?? '',
      "securityAnswer": securityAnswer ?? '',
    };

    if (role == 'Resident' && apartmentNumber.isNotEmpty) {
      body["apartmentNumber"] = apartmentNumber;
    }

    print(" Sending: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));

    print(" Status: ${response.statusCode}");
    print(" Body: ${response.body}");
    return response;
  }

  //  LOGIN
  static Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    ).timeout(const Duration(seconds: 15));

    print(" Login Status: ${response.statusCode}");
    print(" Login Body: ${response.body}");
    return response;
  }
//dashbord statictic
static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/stats'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      }
      return {"totalResidents": 0, "pendingApprovals": 0, "securityStaff": 0};
    } catch (e) {
      return {"totalResidents": 0, "pendingApprovals": 0, "securityStaff": 0};
    }
}
 //get account status pending
static Future<List<dynamic>> getPendingUsers() async {
  try {
 
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/pending'), 
      headers: headers,
    ).timeout(const Duration(seconds: 15));

    print(" Pending Status: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  } catch (e) {
    print("❌ getPendingUsers Error: $e");
    return [];
  }
}
//approve function
  static Future<bool> approveUser(int userId, String status) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/activate'),
      headers: headers,
      body: jsonEncode({
        "userId": userId,  
        "status": status,  
      }),
    ).timeout(const Duration(seconds: 15));

    return response.statusCode == 200;
  } catch (e) {
    print("approveUser Error: $e");
    return false;
  }
}
// get all account 
static Future<List<dynamic>> getAllUsers() async {
  try {
   
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/active'), 
      headers: headers,
    ).timeout(const Duration(seconds: 15));

    print(" Status Code: ${response.statusCode}");
    print(" Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  } catch (e) {
    print("❌ Error: $e");
    return [];
  }
}

  // update info user
  static Future<bool> updateUser(int userId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/update/$userId'), 
        headers: headers,
        body: jsonEncode(updatedData),
      ).timeout(const Duration(seconds: 15));

      print(" Update Status: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print(" updateUser Error: $e");
      return false;
    }
  }

  //delete user
  static Future<bool> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/delete/$userId'), 
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      print(" Delete Status: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print(" deleteUser Error: $e");
      return false;
    }
  }
 //get pending events
   static Future<List<dynamic>> getPendingEvents() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/admin/events/pending'), headers: headers);
      return res.statusCode == 200 ? jsonDecode(res.body) : [];
    } catch (e) { return []; }
  }
//get approved events
  static Future<List<dynamic>> getApprovedEvents() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/admin/events/approved'), headers: headers);
      return res.statusCode == 200 ? jsonDecode(res.body) : [];
    } catch (e) { return []; }
  }
// create  admin events
  static Future<bool> createAdminEvent(Map<String, dynamic> data) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/api/admin/events/create'), headers: headers, body: jsonEncode(data));
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) { return false; }
  }
  //get admin events 
 static Future<List<dynamic>> getAdminOnlyEvents() async {
  try {
    final res = await http.get(
      Uri.parse('$baseUrl/api/admin/events/my-events'), 
      headers: headers
    );
    
    if (res.statusCode == 200) {
      final decodedData = jsonDecode(res.body);
      if (decodedData is Map) {
        return decodedData['events'] ?? decodedData['data'] ?? [];
      } 
      if (decodedData is List) {
        return decodedData;
      }
    }
    return [];
  } catch (e) {
    print("Decoding Error: $e");
    
    return [];
  }
}
static Future<Map<String, dynamic>> manageEventStatus(int eventId, String status) async {
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/api/admin/events/manage'),
      headers: headers,
      body: jsonEncode({
        "eventId": eventId, 
        "status": status    
      }),
    );

    final data = jsonDecode(res.body);
   
    return {
      "success": res.statusCode == 200 && data['success'] == true,
      "message": data['message'] ?? "Unknown error occurred"
    };
  } catch (e) {
    return {"success": false, "message": "Connection error: $e"};
  }
}
static Future<http.Response> updateAdminEvent(String eventId, Map<String, dynamic> data) async {
  return await http.put(
    Uri.parse('$baseUrl/api/admin/events/update/$eventId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
}
// night mode 
static Future<void> updateNightMode(bool isNight) async {
  try {
    await http.post(
      Uri.parse('$baseUrl/api/iot/night-mode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nightMode': isNight}),
    );
  } catch (e) {
    print("Error updating night mode: $e");
  }
}

// fonction light
static Future<Map<String, dynamic>> getLightingState() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/iot/lighting-state'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body); 
    }
  } catch (e) {
    print("Error getting lighting state: $e");
  }
  return {'lightStatus': 'off', 'nightMode': false}; 
}
//alerts
static Future<List<dynamic>> getAllAlerts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/alerts'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
       
        return body['data'] ?? []; 
      }
    } catch (e) {
      print("Error fetching alerts: $e");
    }
    return [];
  }

  //update alerts
  
  static Future<Map<String, dynamic>> updateAlertStatus(int id, String status) async {
    try {
      final response = await http.put(
       Uri.parse('$baseUrl/api/admin/alerts/$id/status'), 
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": status}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
 static Future<List<dynamic>> getActiveResidents() async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/api/admin/residents/active"),
      headers: {"Content-Type": "application/json"},
    );

    
    print("Fetching from: ${response.request?.url}");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      
  
      if (decoded is List) return decoded;
      
     
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] ?? [];
      }
      
      return [];
    } else {
      print("Server Error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Connection Error: $e");
    return [];
  }
}
  //get staff's
  static Future<List<dynamic>> getStaffList() async {
    try {
    
      final response = await http.get(Uri.parse('$baseUrl/api/admin/staff-list'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return body['data'] ?? [];
      }
    } catch (e) {
      print("Error fetching staff: $e");
    }
    return [];
  }

  // assign rask to staff's
  static Future<Map<String, dynamic>> assignTaskToStaff(int alertId, int staffId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/alerts/$alertId/assign'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"staff_id": staffId}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
}
//chat
  // get convarsation
  static Future<List<dynamic>> getConversations(int userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/chat/inbox/$userId"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      }
    } catch (e) {
      print("Inbox Error: $e");
    }
    return [];
  }

  // get chat hesitory
  static Future<List<dynamic>> getChatHistory(int u1, int u2) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/chat/history/$u1/$u2"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("History Error: $e");
    }
    return [];
  }

  // send message
  static Future<bool> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/chat/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_id": senderId,
          "receiver_id": receiverId,
          "content": content,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Send Error: $e");
      return false;
    }
  }
  static Future<Map<String, dynamic>?> getAdminInfo() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/admin/admin-info'));
   

   
    print("Admin Info Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
    
      if (data['success'] == true) {
        return data['data'];
      } 
     
      return data; 
    }
  } catch (e) {
    print("Error fetching admin info: $e");
  }
  return null;
}
//delete message
 static Future<bool> deleteMessage(String messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/chat/delete-message/$messageId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Delete Error: $e");
      return false;
    }
  }
  //edit message
  static Future<bool> editMessage(String messageId, String newContent) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/api/chat/edit-message/$messageId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newContent': newContent}),
    );
    return response.statusCode == 200;
  } catch (e) {
    print("Edit Error: $e");
    return false;
  }
}  

// guest list
static Future<List<dynamic>> getAllGuestsForAdmin() async {
  final String fullUrl = '$baseUrl/api/visitor/admin/all-guests';
  print(" Calling: $fullUrl");

  try {
    final response = await http.get(
      Uri.parse(fullUrl),
      headers: {'Content-Type': 'application/json'},
    );

   
    print(" Server Response: ${response.body}"); 

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      
      if (decodedData is Map && decodedData.containsKey('data')) {
        print("Found data key with ${decodedData['data'].length} items");
        return decodedData['data'] as List<dynamic>;
      } 
      
      if (decodedData is List) {
        return decodedData;
      }
    }
    print(" Status Code: ${response.statusCode}");
    return [];
  } catch (e) {
    print(" Connection Error: $e");
    return [];
  }
}
//notification
static Future<List<dynamic>> getUserNotifications(String userId) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/notifications/by-user/$userId')); 
    
    print(" API RESPONSE STATUS: ${response.statusCode}");
    print(" API RESPONSE BODY: ${response.body}"); 

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      
    
      if (decodedData is Map && decodedData.containsKey('data') && decodedData['data'] is List) {
        return decodedData['data'];
      }
    }
    return [];
  } catch (e) {
    print("Error fetching notifications in ApiService: $e");
    return [];
  }
}


static Future<bool> markNotificationAsRead(dynamic notificationId) async {
 
  final url = Uri.parse('$baseUrl/api/notifications/mark-as-read/$notificationId');

  try {
    print(" Sending PUT to: $url");
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['success'] == true;
    }
    return false;
  } catch (e) {
    print(" Error updating notification status: $e");
    return false;
  }
}
}