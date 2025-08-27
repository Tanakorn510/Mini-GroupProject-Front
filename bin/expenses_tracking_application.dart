// for http connection
import 'package:http/http.dart' as http;
// for stdin
import 'dart:io';
import 'dart:convert';

void main() async {
  await login();
}


//==========================================================
// login function
//==========================================================
Future<void> login() async {
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
  final response = await http.post(url, body: body);
  // note: if body is Map, it is encoded by "application/x-www-form-urlencoded" not JSON
  if (response.statusCode == 200) {
    // the response.body is String
     final result = jsonDecode(response.body) as Map<String, dynamic>;
     choose(result['id'].toString(), result['username'].toString());
    
    // await getprofileAll(result['id'].toString());
    // print(result['id']);
   
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    final result = response.body;
    print(result);
  } else {
    print("Unknown error");
  }
}

//==========================================================
// Function to decide what to do after login
//==========================================================
Future<void> choose(String userId, username) async {
  while (true){
      print("");
      print("========== Expense Tracking App ==========");
      print("Welcome $username");
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
          await showExpenses(userId, onlyToday: false);
          // Call function to fetch all expenses
          break;
        case '2':
          await showExpenses(userId, onlyToday: true);
          // Call function to fetch today's expense
          break;
        case '3':
          await searchExpenses(userId);
          // Call function to search for an expense
          break;
        case '4':
          await addExpenses(userId);
          // Call function to add a new expense
          break;
        case '5':
          await deleteExpenses(userId);
          // Call function to delete an expense
          break;
        case '6':
          print("----- Bye -----");
          return; 
        default:
          print("Invalid choice, please try again.");
      }
      
    }
}


//==========================================================
// add feature here
//==========================================================
Future<void> addExpenses(String userId) async {
  print("===== Add new item =====");
  stdout.write("Item: ");
  String item = stdin.readLineSync()!;

  stdout.write("Paid: ");
  int paid = int.parse(stdin.readLineSync()!);

  final url = Uri.parse("http://localhost:3000/add_expenses/$userId"); 
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      
      "item": item,
      "paid": paid
    }),
  );

  if (response.statusCode == 200) {
    print("Inserted!");
  } else {
    print(" Failed to add expense: ${response.body}");
  }
}
// ==========================================================
// delete feature here
//==========================================================
Future<void> deleteExpenses(String userId) async {
  print("===== Delete an item =====");
  stdout.write("Item id: ");
  int expenseId = int.parse(stdin.readLineSync()!);

  final url = Uri.parse("http://localhost:3000/delete_expenses/$userId");
  final response = await http.delete(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"id": expenseId}),
  );

  if (response.statusCode == 200) {
    print("Deleted!");
  } else {
    print(" Failed to delete expense: ${response.body}");
  }
}

//==========================================================
// search funtion
//==========================================================
Future<void> searchExpenses(String userId) async {
  print("");
  stdout.write("Item to search: ");
  String? keyword = stdin.readLineSync()?.trim();

  if (keyword == null || keyword.isEmpty) {
    print("Search keyword cannot be empty.");
    return;
  }

  final url = Uri.parse('http://localhost:3000/show_expense/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final allExpenses = jsonDecode(response.body) as List<dynamic>;
    
    // Filter expenses based on the keyword (case-insensitive)
    final foundItems = allExpenses.where((expense) {
      final item = expense['item'].toString().toLowerCase();
      return item.contains(keyword.toLowerCase());
    }).toList();

    if (foundItems.isEmpty) {
      print("No item: $keyword");
    } else {
      for (var expense in foundItems) {
         final date = DateTime.parse(expense['date']).toLocal();
         // ใช้ format date and time ให้เหมือนกับในรูปตัวอย่าง
         final formattedDateTime = 
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} " +
            "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}.${date.millisecond.toString().padLeft(3, '0')}";

        print("${expense['id']}. ${expense['item']} : ${expense['paid']}฿ : $formattedDateTime");
      }
    }
  } else {
    print("Failed to fetch expenses: ${response.body}");
  }
}

//==========================================================
// Function to fetch all expenses
//==========================================================
Future<void> showExpenses(String userId, {bool onlyToday = false}) async {
  final url = Uri.parse('http://localhost:3000/show_expense/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body) as List<dynamic>;
    final now = DateTime.now();
    int total = 0;
    print("");
    print(onlyToday
        
        ? "---------- Today's Expenses -----------"
        : "---------- All Expenses -----------");

    for (var expense in result) {
      final date = DateTime.parse(expense['date']).toLocal();

      // ถ้า onlyToday = true → filter แค่ของวันนี้
      if (!onlyToday ||
          (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day)) {
        final formattedDate =
            "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
        print("${expense['id']}. ${expense['item']} : ${expense['paid']}฿ : $formattedDate");
        total += expense['paid'] as int;
      }
    }
    if (total == 0) {
      print(onlyToday ? "No expenses today" : "No expenses found");
    }
    print("Total expenses${onlyToday ? ' today' : ''} = ${total}฿");
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    print(response.body);
  } else {
    print("Unknown error");
  }
}