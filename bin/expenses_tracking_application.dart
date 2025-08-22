// for http connection
import 'package:http/http.dart' as http;
// for stdin
import 'dart:io';


void main() async {
  print("===== Login =====");
  // Get username and password
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  // ตรวจสอบ username ต้องเป็นตัวอักษร (ไทย/อังกฤษ)
  final usernameRegExp = RegExp(r'^[a-zA-Zก-๙]+$');
  // ตรวจสอบ password ต้องเป็นตัวเลข
  final passwordRegExp = RegExp(r'^\d+$');

  if (username == null || password == null || username.isEmpty || password.isEmpty) {
    print("Incomplete input");
    return;
  }

  if (!usernameRegExp.hasMatch(username)) {
    print("Username has to be letters (Thai/English) only");
    return;
  }

  if (!passwordRegExp.hasMatch(password)) {
    print("Password has to be numbers only");
    return;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: body
);

  if (response.statusCode == 200) {
    print("Welcome, $username");
    while (true){
      
      print("========== Expense Tracking App ==========");
      print("1. All expenses");
      print("2. Today's expense");
      print("3. Search expense");
      print("4. Add new expense");
      print("5. Delete an expense");
      print("6. Exit");
      stdout.write("Choose... ");
      String? choice = stdin.readLineSync()?.trim();

      switch (choice) {
        case '1':
          
          // Call function to fetch all expenses
          break;
        case '2':
          
          // Call function to fetch today's expense
          break;
        case '3':
          
          // Call function to search for an expense
          break;
        case '4':
          
          // Call function to add a new expense
          break;
        case '5':
          
          // Call function to delete an expense
          break;
        case '6':
          print("Exiting...");
          return; 
        default:
          print("Invalid choice, please try again.");
      }
      
    }
    
  } else if (response.statusCode == 401 || response.statusCode == 500) {
     // the response.body is String
    final result = response.body;
    print(result);
  } else {
    print("Unknown error");
  }
}

