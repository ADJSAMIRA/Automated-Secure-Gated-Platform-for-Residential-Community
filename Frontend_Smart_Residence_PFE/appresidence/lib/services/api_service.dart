import 'dart:convert';
//import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class ApiService {
  
  static const String baseUrl = "https://fleece-ratios-toolbar-alliance.trycloudflare.com";

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
    final url = Uri.parse("$baseUrl/api/auth/signup");

    final Map<String, dynamic> body = {
      "fullName": fullName,
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber,
      "role": role ?? role ,
      "security_question": securityQuestion ?? '',
      "securityAnswer": securityAnswer ?? '',
    };

    //  apartmentNumber Resident
    if (role == 'Resident') {
      body["apartmentNumber"] = apartmentNumber;
    }

    print(" Sending to: $url");
    print(" Body: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));

    print(" Status: ${response.statusCode}");
    print(" Body: ${response.body}");
    return response;
  }

  //  LOGIN
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    ).timeout(const Duration(seconds: 15));

    print(" Login Status: ${response.statusCode}");
    print(" Login Body: ${response.body}");
    return response;
  }
  
 static Future<http.Response> getResidentProfile(String userId) async {
  final url = Uri.parse("$baseUrl/api/resident/profile/$userId"); 
  return await http.get(url, headers: {"Content-Type": "application/json"});
}

static Future<http.Response> getResidentStats(String userId) async {
  final url = Uri.parse("$baseUrl/api/resident/stats/$userId");
  return await http.get(url, headers: {"Content-Type": "application/json"});
}

 //  EVENTS 

  // get list events
  static Future<http.Response> listEvents(String userId) async {
    final url = Uri.parse("$baseUrl/api/resident/events?userId=$userId");
    return await http.get(url, headers: {"Content-Type": "application/json"});
  }

  //create event
  static Future<http.Response> createEvent(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/api/resident/events");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  // get all resident list
  static Future<List<dynamic>> getAllResidents() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/resident/all-residents"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching residents: $e");
      return [];
    }
  }

  //get participent
  static Future<List<dynamic>> getParticipants(String eventId) async {
    try {
      final url = Uri.parse("$baseUrl/api/resident/events/$eventId/participants");
      final response = await http.get(url, headers: {"Content-Type": "application/json"});
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  // reponse of invitantion
  static Future<http.Response> respondToInvite(String eventId, String userId, String status) async {
    final url = Uri.parse("$baseUrl/api/resident/events/respond");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "eventId": eventId,
        "userId": userId,
        "status": status, // 'Accepted or'Declined'
      }),
    );
  }

  // delete event
  static Future<http.Response> deleteEvent(String eventId, String userId) async {
    final url = Uri.parse("$baseUrl/api/resident/events/$eventId");
    return await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );
  }

  static Future<http.Response> joinEvent(String eventId, String userId) async {
  return await http.post(
    Uri.parse('$baseUrl/resident/events/join'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'eventId': eventId, 'userId': userId}),
  );
}

//reservation sherd spaces

  static Future<List<dynamic>> getSharedSpaces() async {
    try {
      print(" Fetching spaces from: $baseUrl/api/resident/shared-spaces");
      final response = await http.get(
        Uri.parse('$baseUrl/api/resident/shared-spaces'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Shared Spaces Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // virifier the data in map 
        if (decoded is Map && decoded.containsKey('data')) {
          return List<dynamic>.from(decoded['data']);
        }
        return List<dynamic>.from(decoded);
      } 
      return [];
    } catch (e) {
      print("❌ Error in getSharedSpaces: $e");
      return [];
    }
  }

  // my reservations
  static Future<List<dynamic>> getUpcomingReservations(String userId) async {
    try {
      print(" Fetching reservations for user: $userId");
      final response = await http.get(
        Uri.parse('$baseUrl/api/resident/reservations/upcoming/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Reservations Status: ${response.statusCode}");
      print(" Reservations Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        
        if (decoded is Map) {
          if (decoded.containsKey('data')) {
            return List<dynamic>.from(decoded['data']);
          } else if (decoded.containsKey('reservations')) {
             return List<dynamic>.from(decoded['reservations']);
          } else {
             return []; 
          }
        }
        
        return List<dynamic>.from(decoded);
      } else {
        return [];
      }
    } catch (e) {
      print(" Error in getUpcomingReservations: $e");
      return [];
    }
  }

  // submit reservation
  static Future<http.Response> createReservation(Map<String, dynamic> data) async {
    try {
      print("data being sent: $data");
      print(" Submitting reservation to: $baseUrl/api/resident/reservations");
      final response = await http.post(
        Uri.parse('$baseUrl/api/resident/reservations'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));
      
      print(" Create Reservation Status: ${response.statusCode}");
      return response;
    } catch (e) {
      print(" Error in createReservation: $e");
      throw Exception("Connection Failed");
    }
  }
 // update reservation
  static Future<http.Response> updateReservation(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/resident/reservations/$id');
    return await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
  }

  // delete reservation
  static Future<http.Response> deleteReservation(int id, int userId) async {
    final url = Uri.parse('$baseUrl/api/resident/reservations/$id');
    return await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"userId": userId}),
    );
  }
  //alerts
 // report alert
  static Future<http.Response> reportAlert(Map<String, dynamic> data) async {
    
    final url = Uri.parse('$baseUrl/api/resident/alerts'); 
    try {
      return await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // get list my report
  static Future<http.Response> getAlertHistory(String userId) async {
   
    final url = Uri.parse('$baseUrl/api/resident/alerts/history/$userId');
    try {
      return await http.get(
        url,
        headers: {"Accept": "application/json"},
      );
    } catch (e) {
      rethrow;
    }
  }
  //login staff
static Future<bool> updateJobType(String userId, String jobType) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/api/auth/update-job-type/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'job_type': jobType}),
    );
   
    print("Response Status: ${response.statusCode}"); 
    return response.statusCode == 200;
  } catch (e) {
    print("API Error: $e");
    return false;
  }
}
//chat
// unbox epaingle admin
  static Future<List<dynamic>> getUserInbox(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/chat/inbox/$userId'));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }


  //search resident
  static Future<List<dynamic>> searchResidents(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/resident/search?q=$query'));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // date of conversation
   static Future<List<dynamic>> getChatHistory(String u1, String u2) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/chat/history/$u1/$u2'));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // send chat
  static Future<bool> sendMessage(String sender, String receiver, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': sender,
          'receiver_id': receiver,
          'content': content
        }),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
  static Future<Map<String, dynamic>?> getAdminInfo() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/chat/admin-info'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true ? data['data'] : null;
      }
    } catch (e) { print("Error: $e"); }
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
// guest invite
//submit guest
static Future<Map<String, dynamic>> registerGuest(Map<String, dynamic> guestData) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/visitor/register'),
      
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(guestData),
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {'success': false, 'message': 'Connection error: $e'};
  }
}
//list my guest
static Future<List<dynamic>> getMyGuests(String apartmentId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/visitor/my-guests/$apartmentId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      if (decodedData['success'] == true) {
        return decodedData['data']; 
      }
    }
    return [];
  } catch (e) {
    print("Error fetching guests: $e");
    return [];
  }
}
//security interface
// get info security
static Future<Map<String, dynamic>> getSecurityHome(String id) async {
  final url = Uri.parse("$baseUrl/api/security/home/$id"); 
  final response = await http.get(url, headers: {"Accept": "application/json"});

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load security home data");
  }
}
//get tasks for security
 static Future<List<dynamic>> getSecurityTasks(String userId) async {
  final url = Uri.parse('$baseUrl/api/security/tasks/$userId');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData['success'] == true && decodedData['data'] != null) {
        return decodedData['data'] as List<dynamic>;
      }
      return [];
    }
    return [];
  } catch (e) {
    print("Error: $e");
    return [];
  }
}
//update task
static Future<bool> updateSecurityTask(String taskId, String status, {String remarks = ""}) async {
  final url = Uri.parse('$baseUrl/api/security/tasks/$taskId/update');
  
  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'status': status,
        'remarks': remarks,
      }),
    );
    
    print("Server Response Status: ${response.statusCode}");
    print("Server Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("Network/Flutter Error: $e");
    return false;
  }
}
//stats security
static Future<Map<String, dynamic>> getSecurityStats(String staffId) async {
  final url = Uri.parse('$baseUrl/api/security/stats/$staffId');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data'] ?? {};
    }
    return {};
  } catch (e) {
    print("Error fetching security stats: $e");
    return {};
  }
}
//parking resident
 static Future<List<dynamic>> getParkingSpots() async {
    try {
     
      final response = await http.get(Uri.parse('$baseUrl/api/iot/parking-spots'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success']) {
          return data['spots'];
        }
      }
      return [];
    } catch (e) {
      print("Error fetching parking spots: $e");
      return [];
    }
  }
// notification

static Future<List<dynamic>> getUserNotifications(String userId) async {
  final url = Uri.parse('$baseUrl/api/notifications/by-user/$userId');
 
  try {
    print(" Fetching notifications from: $url");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        return decoded['data'] ?? []; 
      }
    }
    return [];
  } catch (e) {
    print(" Error fetching notifications: $e");
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
//community feed
static Future<http.Response> getCommunityFeed() async {
  return await http.get(Uri.parse('$baseUrl/feed'));
}

static Future<http.Response> createNewPost(String authorId, String content, String type) async {
  return await http.post(
    Uri.parse('$baseUrl/posts'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"author_id": authorId, "content": content, "postType": type}),
  );
}

static Future<http.Response> getPostComments(String postId) async {
  return await http.get(Uri.parse('$baseUrl/posts/$postId/comments'));
}

static Future<http.Response> addPostComment(String postId, String authorId, String text) async {
  return await http.post(
    Uri.parse('$baseUrl/posts/$postId/comments'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"author_id": authorId, "text": text}),
  );
}

static Future<http.Response> likePostToggle(String postId, String userId) async {
  return await http.post(
    Uri.parse('$baseUrl/posts/$postId/like'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"userId": userId}),
  );
}
}
