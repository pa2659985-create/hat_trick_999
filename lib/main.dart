import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase Background Init Error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Dotenv Load Error: $e');
  }

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('Firebase Init Error: $e');
  }

  // အက်ပ်စစချင်း Cloud Firestore မှ ဒေတာများကို အရင်ဆွဲထုတ်မည်
  await AppData.loadData();
  
  runApp(const HatTrickApp());
}

class AppStrings {
  static Map<String, Map<String, String>> localizedValues = {
    'မြန်မာ': {
      'appTitle': 'Hat Trick',
      'balance': 'လက်ကျန်ငွေ',
      'points': 'လက်ဆောင် ပွိုင့်များ',
      'betAmount': 'လောင်းထားသောငွေ',
      'parlay': 'မောင်း (Parlay)',
      'single': 'ဘော်ဒီ/ဂိုးပေါင်း',
      'myBets': 'လောင်းထားသောပွဲစဉ်များ',
      'oldMatches': 'ပွဲစဉ်ဟောင်းများ',
      'wallet': 'ငွေစာရင်း',
      'results': 'ပွဲပြီး ရလဒ်များ',
      'standings': 'အဆင့်ဇယား',
      'exchange': 'ပွိုင့်လဲလှယ်',
      'terms': 'စည်းကမ်းသတ်မှတ်ချက်များ',
      'changePass': 'စကားဝှက် ပြောင်းရန်',
      'teamName': 'အသင်း/အမည်',
      'language': 'ဘာသာစကားရွေးရန်',
      'logout': 'ထွက်ရန်',
      'adminPanel': 'Admin ထိန်းချုပ်ရန်',
    },
    'English': {
      'appTitle': 'Hat Trick',
      'balance': 'Balance',
      'points': 'Bonus Points',
      'betAmount': 'Active Bet Amount',
      'parlay': 'Parlay',
      'single': 'Single / Over Under',
      'myBets': 'My Bets',
      'oldMatches': 'Match History',
      'wallet': 'Wallet',
      'results': 'Finished Results',
      'standings': 'Standings',
      'exchange': 'Points Exchange',
      'terms': 'Terms & Conditions',
      'changePass': 'Change Password',
      'teamName': 'Team / Name',
      'language': 'Select Language',
      'logout': 'Logout',
      'adminPanel': 'Admin Control Panel',
    }
  };

  static String get(String key) {
    return localizedValues[AppData.selectedLanguage]?[key] ?? localizedValues['မြန်မာ']![key]!;
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    Widget initialScreen = const LoginScreen();
    if (AppData.username.isNotEmpty) {
      if (AppData.isAdmin) {
        initialScreen = const AdminPanelScreen();
      } else {
        initialScreen = const DashboardScreen();
      }
    }
    return initialScreen;
  }
}

class HatTrickApp extends StatefulWidget {
  const HatTrickApp({super.key});

  static void setLocale(BuildContext context, String lang) {
    _HatTrickAppState? state = context.findAncestorStateOfType<_HatTrickAppState>();
    state?.setLanguage(lang);
  }

  @override
  State<HatTrickApp> createState() => _HatTrickAppState();
}

class _HatTrickAppState extends State<HatTrickApp> {
  void setLanguage(String lang) {
    setState(() {
      AppData.selectedLanguage = lang;
    });
    AppData.saveData();
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Foreground Notification: ${message.notification!.title}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hat Trick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B12),
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF132E1B),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class ApiService {
  static String get apiKey {
    try {
      return dotenv.env['FOOTBALL_API_KEY'] ?? '5a87133d1c764efb8525d81e82d605fd';
    } catch (_) {
      return '5a87133d1c764efb8525d81e82d605fd';
    }
  }
  static const String baseUrl = 'https://api.football-data.org/v4/matches';

  static List<Map<String, dynamic>> customAdminMatches = [];

  static Future<List<Map<String, dynamic>>> fetchMatches() async {
    try {
      var matchSnapshot = await FirebaseFirestore.instance.collection('settings').doc('matches_data').get();
      if (matchSnapshot.exists && matchSnapshot.data()?['matches'] != null) {
        List storedMatches = matchSnapshot.data()?['matches'];
        customAdminMatches = storedMatches.map((e) => Map<String, dynamic>.from(e)).toList();
        return customAdminMatches;
      }
    } catch (e) {
      print('Firestore Matches Load Error: $e');
    }

    if (customAdminMatches.isNotEmpty) {
      return customAdminMatches;
    }

    List<Map<String, dynamic>> allMatches = [];

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List matches = data['matches'] ?? [];
        
        for (var m in matches) {
          String rawTime = m['utcDate'] != null ? m['utcDate'].toString() : '2026-09-14T15:00:00Z';
          String formattedDateTime = _formatDateTimeToDDMMYYYYAMPM(rawTime);

          allMatches.add({
            'id': '${m['id']}',
            'league': m['competition']?['name'] ?? 'League',
            'time': formattedDateTime,
            't1': m['homeTeam']?['name'] ?? 'Home Team',
            't2': m['awayTeam']?['name'] ?? 'Away Team',
            'status': m['status'] ?? 'UPCOMING',
            'odds': {
              'homeOddsText': '= -25',
              'awayOddsText': '1.95',
              'goalLineText': '3 +80',
              'overOdds': 1.90,
              'underOdds': 1.85,
            }
          });
        }
      }
    } catch (e) {
      print('API Error: $e');
    }

    if (allMatches.length < 5) {
      allMatches.addAll([
        {
          'id': 'auto_m1',
          'league': 'Indonesia Super League',
          'time': '14-09-2026, 03:00 pm',
          't1': 'B ဆိုလို FC',
          't2': 'P ဆူရာဘាយ',
          'status': 'UPCOMING',
          'odds': {'homeOddsText': '= -25', 'awayOddsText': '1.95', 'goalLineText': '3 +80', 'overOdds': 1.85, 'underOdds': 1.90}
        },
        {
          'id': 'auto_m2',
          'league': 'Indonesia Super League',
          'time': '14-09-2026, 03:00 pm',
          't1': 'ပါဆစ် K',
          't2': 'ဒီဝါ Utd FC',
          'status': 'UPCOMING',
          'odds': {'homeOddsText': '= -75', 'awayOddsText': '1.95', 'goalLineText': '3 +35', 'overOdds': 1.75, 'underOdds': 2.00}
        },
      ]);
    }

    customAdminMatches = allMatches;
    return allMatches;
  }

  static Future<void> saveMatchesToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('settings').doc('matches_data').set({
        'matches': customAdminMatches,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firestore Matches Save Error: $e');
    }
  }

  static String _formatDateTimeToDDMMYYYYAMPM(String utcDateStr) {
    try {
      DateTime dt = DateTime.parse(utcDateStr).toLocal();
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();
      
      int hour = dt.hour;
      String period = hour >= 12 ? 'pm' : 'am';
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;
      String minute = dt.minute.toString().padLeft(2, '0');

      return '$day-$month-$year, $hour:$minute $period';
    } catch (e) {
      return '14-09-2026, 03:00 pm';
    }
  }

  static Future<List<Map<String, dynamic>>> fetchOldMatches() async {
    List<Map<String, dynamic>> oldMatches = [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?status=FINISHED'),
        headers: {'X-Auth-Token': apiKey},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List matches = data['matches'] ?? [];
        for (var m in matches) {
          final score = m['score']?['fullTime'] ?? {'home': 0, 'away': 0};
          oldMatches.add({
            'matchId': '${m['id']}',
            'league': m['competition']?['name'] ?? 'League',
            'match': '${m['homeTeam']?['name']} vs ${m['awayTeam']?['name']}',
            'homeScore': score['home'] ?? 0,
            'awayScore': score['away'] ?? 0,
            'score': '${score['home'] ?? 0} - ${score['away'] ?? 0}',
            'date': m['utcDate'] != null ? m['utcDate'].substring(0, 10) : '2026-09-13',
            'result': 'ပြီးဆုံး (FT)',
          });
        }
      }
    } catch (e) {
      print('Old Matches API Error: $e');
    }
    if (oldMatches.isEmpty) {
      oldMatches.addAll([
        {
          'matchId': 'm_sample_1',
          'league': 'Indonesia Super League',
          'match': 'B ဆိုလို FC vs P ဆူရာဘាយ',
          'homeScore': 2,
          'awayScore': 1,
          'score': '2 - 1',
          'date': '2026-09-13',
          'result': 'ပြီးဆုံး (FT)',
        },
      ]);
    }
    return oldMatches;
  }

  static Future<List<Map<String, dynamic>>> fetchStandings() async {
    List<Map<String, dynamic>> standings = [];
    try {
      final response = await http.get(
        Uri.parse('https://api.football-data.org/v4/competitions/2021/standings'),
        headers: {'X-Auth-Token': apiKey},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var table = data['standings']?[0]?['table'] ?? [];
        for (var row in table) {
          standings.add({
            'pos': row['position'],
            'team': row['team']?['name'] ?? '',
            'played': row['playedGames'],
            'points': row['points'],
          });
        }
      }
    } catch (e) {
      print('Standings Error: $e');
    }
    if (standings.isEmpty) {
      standings.add({'pos': 1, 'team': 'Manchester City', 'played': 5, 'points': 15});
      standings.add({'pos': 2, 'team': 'Arsenal', 'played': 5, 'points': 13});
    }
    return standings;
  }
}

class AppData {
  static String displayName = 'မင်းမင်းအောင်';
  static String username = '';
  static double balance = 0.0;
  static int points = 0;
  static String selectedTeam = 'မြန်မာ (Myanmar)';
  static String selectedLanguage = 'မြန်မာ';
  static bool isAdmin = false;
  static bool isMaintenanceMode = false;

  static List<Map<String, dynamic>> activeBets = [];
  static List<Map<String, dynamic>> parlaySlip = []; 

  static List<Map<String, dynamic>> allUsers = [];

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    selectedTeam = prefs.getString('selectedTeam') ?? 'မြန်မာ (Myanmar)';
    selectedLanguage = prefs.getString('selectedLanguage') ?? 'မြန်မာ';
    displayName = prefs.getString('displayName') ?? 'မင်းမင်းအောင်';
    isAdmin = prefs.getBool('isAdmin') ?? false;

    try {
      var settingsDoc = await FirebaseFirestore.instance.collection('settings').doc('app_config').get();
      if (settingsDoc.exists) {
        isMaintenanceMode = settingsDoc.data()?['isMaintenanceMode'] ?? false;
      }
    } catch (e) {
      print('Settings Load Error: $e');
    }

    // Cloud Firestore မှ users အားလုံးကို အမြဲတမ်း 100% တိကျစွာ ဆွဲထုတ်မည်
    try {
      var usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      allUsers.clear();

      if (usersSnapshot.docs.isNotEmpty) {
        for (var doc in usersSnapshot.docs) {
          var data = doc.data();
          allUsers.add({
            'username': doc.id,
            'password': data['password'] ?? 'pass123',
            'balance': (data['balance'] ?? 10000.0).toDouble(),
            'points': data['points'] ?? 100,
            'displayName': data['displayName'] ?? doc.id,
          });
        }
      }

      // မရှိသေးပါက Default မန်ဘာ ၁၀၀ ကို ဖန်တီးပေးမည်
      if (allUsers.isEmpty) {
        for (int i = 1; i <= 100; i++) {
          String uName = 'member$i';
          String pass = 'pass$i';
          double bal = 10000.0 * (i % 5 + 1);
          int pts = 100 * (i % 3 + 1);

          allUsers.add({
            'username': uName,
            'password': pass,
            'balance': bal,
            'points': pts,
            'displayName': uName,
          });

          await FirebaseFirestore.instance.collection('users').doc(uName).set({
            'displayName': uName,
            'password': pass,
            'balance': bal,
            'points': pts,
          });
        }
      }
    } catch (e) {
      print('Cloud Firestore Users Load Error: $e');
    }

    if (username.isNotEmpty && username != '999admin') {
      var matchedUser = allUsers.firstWhere(
        (element) => element['username'] == username,
        orElse: () => {},
      );
      if (matchedUser.isNotEmpty) {
        balance = (matchedUser['balance'] as num).toDouble();
        points = matchedUser['points'] as int;
        displayName = matchedUser['displayName'] ?? username;
      }

      try {
        var betsSnapshot = await FirebaseFirestore.instance.collection('users').doc(username).collection('bets').get();
        activeBets = betsSnapshot.docs.map((doc) => doc.data()).toList();
      } catch (e) {
        print('Bets Load Error: $e');
      }
    }
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('selectedTeam', selectedTeam);
    await prefs.setString('selectedLanguage', selectedLanguage);
    await prefs.setString('displayName', displayName);
    await prefs.setBool('isAdmin', isAdmin);

    try {
      await FirebaseFirestore.instance.collection('settings').doc('app_config').set({
        'isMaintenanceMode': isMaintenanceMode,
      }, SetOptions(merge: true));

      if (username.isNotEmpty && username != '999admin') {
        await FirebaseFirestore.instance.collection('users').doc(username).set({
          'displayName': displayName,
          'balance': balance,
          'points': points,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Cloud Firestore Save Error: $e');
    }
  }

  static Future<void> saveBetToFirestore(Map<String, dynamic> betData) async {
    try {
      if (username.isNotEmpty && username != '999admin') {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .collection('bets')
            .doc(betData['betId'])
            .set(betData);
      }
    } catch (e) {
      print('Firestore Bet Save Error: $e');
    }
  }

  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.setBool('isAdmin', false);
    username = '';
    isAdmin = false;
    balance = 0.0;
    points = 0;
    activeBets.clear();
  }

  static Future<void> autoCheckAndSettleBets() async {
    try {
      List<Map<String, dynamic>> finishedMatches = await ApiService.fetchOldMatches();
      if (finishedMatches.isEmpty) return;

      for (var bet in activeBets) {
        if (bet['status'] != 'ACTIVE') continue;

        bool isAllWon = true;
        bool isAnyLost = false;
        bool allMatchesFinished = true;

        List matchesInBet = bet['matches'];
        for (var m in matchesInBet) {
          String matchId = m['matchId'];
          var finishedMatch = finishedMatches.firstWhere(
            (element) => element['matchId'] == matchId,
            orElse: () => {},
          );

          if (finishedMatch.isEmpty) {
            allMatchesFinished = false;
            break;
          }

          int homeScore = finishedMatch['homeScore'];
          int awayScore = finishedMatch['awayScore'];
          String betType = m['betType'];
          String selection = m['selection'];

          bool matchWon = false;
          if (betType == 'အနိုင်/အရှုံး') {
            if (selection == m['matchName'].split(' vs ')[0]) {
              matchWon = homeScore > awayScore;
            } else {
              matchWon = awayScore > homeScore;
            }
          } else if (betType == 'ဂိုးပေါင်း (Over/Under)') {
            double totalGoals = (homeScore + awayScore).toDouble();
            double line = 2.5;
            if (selection == 'ဂိုးပေါ် (Over)') {
              matchWon = totalGoals > line;
            } else {
              matchWon = totalGoals < line;
            }
          }

          if (!matchWon) {
            isAnyLost = true;
          }
        }

        if (allMatchesFinished) {
          if (isAnyLost) {
            bet['status'] = 'LOST (အရှုံး)';
          } else if (isAllWon) {
            bet['status'] = 'WON (အနိုင်ရ)';
            balance += (bet['potentialWin'] as double);
          }
          await saveBetToFirestore(bet);
        }
      }
      await saveData();
    } catch (e) {
      print('Auto Settle Error: $e');
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() async {
    String uName = _userController.text.trim();
    String pass = _passController.text.trim();

    if (uName.isNotEmpty && pass.isNotEmpty) {
      if (uName == '999admin' && pass == 'admin999') {
        AppData.isAdmin = true;
        AppData.username = '999admin';
        AppData.displayName = 'စူပါအဓိပတိ (Super Admin)';
        await AppData.saveData();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
        );
        return;
      }

      if (AppData.isMaintenanceMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('အက်ပ်ကို ခတ္တပိတ်ထားပါသည် (Maintenance Mode)။')),
        );
        return;
      }

      // လော့ဂ်အင်မဝင်မီ Cloud မှ ဒေတာအသစ်များကို အကြွင်းမဲ့ ချက်ချင်းဆွဲထုတ်မည်
      await AppData.loadData();

      var matchedUser = AppData.allUsers.firstWhere(
        (element) => element['username'] == uName && element['password'] == pass,
        orElse: () => {},
      );

      if (matchedUser.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('အသုံးပြုသူအမည် သို့မဟုတ် စကားဝှက် မမှန်ကန်ပါ (သို့မဟုတ်) အခွင့်အရေးမရှိပါ။')),
        );
        return;
      }

      AppData.isAdmin = false;
      AppData.username = matchedUser['username'];
      AppData.displayName = matchedUser['displayName'] ?? uName;
      AppData.balance = (matchedUser['balance'] as num).toDouble();
      AppData.points = matchedUser['points'] as int;

      await AppData.saveData();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('အသုံးပြုသူအမည်နှင့် စကားဝှက် ထည့်ပါ။')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage('https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=1000&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.75), BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade800.withOpacity(0.4),
                    border: Border.all(color: Colors.amber.shade400, width: 2),
                  ),
                  child: const Icon(Icons.sports_soccer, size: 64, color: Colors.amberAccent),
                ),
                const SizedBox(height: 16),
                const Text('Hat Trick', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                const Text('⚽ နည်းနည်းလောင်း များများနိုင် ⚽', style: TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: 'အသုံးပြုသူ အမည် (Member 1 to 100)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person, color: Colors.greenAccent),
                    filled: true,
                    fillColor: const Color(0xFF132E1B).withOpacity(0.85),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade800)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'စကားဝှက်',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock, color: Colors.greenAccent),
                    filled: true,
                    fillColor: const Color(0xFF132E1B).withOpacity(0.85),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade800)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    onPressed: _login,
                    child: const Text('အကောင့်ဝင်မည်', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin ထိန်းချုပ်ရေး မာစတာပန်နယ်'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await AppData.clearData();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            tooltip: 'ထွက်ရန်',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('⚙️ အက်ပ်တစ်ခုလုံး မာစတာ ထိန်းချုပ်မှု', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF132E1B),
            child: SwitchListTile(
              title: const Text('အက်ပ်ပိတ်ရန် (Maintenance Mode)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(AppData.isMaintenanceMode ? 'အက်ပ် ပိတ်ထားသည် (User များ ဝင်မရပါ)' : 'အက်ပ် ဖွင့်ထားသည်', style: const TextStyle(color: Colors.grey)),
              value: AppData.isMaintenanceMode,
              activeColor: Colors.red,
              onChanged: (val) async {
                setState(() {
                  AppData.isMaintenanceMode = val;
                });
                await AppData.saveData();
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF132E1B),
            child: ListTile(
              leading: const Icon(Icons.people, color: Colors.greenAccent),
              title: const Text('၁။ တရားဝင် မန်ဘာ (၁၀၀) စာရင်းနှင့် ငွေစာရင်း/စကားဝှက် စီမံရန်', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Member အသစ်ထည့်ခြင်း၊ နာမည်/စကားဝှက်နှင့် ငွေစာရင်းများ ပြင်ဆင်ရန်', style: TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUserManagementScreen()))
                    .then((_) => setState(() {}));
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF132E1B),
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blueAccent),
              title: const Text('၂။ လောင်းကြေးများ အနိုင်/အရှုံး စစ်ဆေးပြီး အတည်ပြုခြင်း', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Active Bets များကို Manual သို့မဟုတ် Auto Settle လုပ်ရန်', style: TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminBetSettlementScreen()))
                    .then((_) => setState(() {}));
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF132E1B),
            child: ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.amberAccent),
              title: const Text('၃။ ပွဲစဉ်များနှင့် Odds များကို စိတ်ကြိုက် စီမံရန် (CRUD)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('ပွဲစဉ်အသစ်ထည့်ခြင်း၊ ပြင်ဆင်ခြင်းနှင့် ဖျက်ခြင်း', style: TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminMatchControlScreen()))
                    .then((_) => setState(() {}));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('တရားဝင် မန်ဘာများ စီမံရန် (CRUD)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.greenAccent),
            onPressed: () => _showAddUserDialog(context),
            tooltip: 'မန်ဘာအသစ် ထည့်ရန်',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: AppData.allUsers.length,
        itemBuilder: (context, index) {
          var user = AppData.allUsers[index];
          return Card(
            color: const Color(0xFF132E1B),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text('Username: ${user['username']} | Pass: ${user['password']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('လက်ကျန်ငွေ: ${user['balance']} Ks | ပွိုင့်: ${user['points']} Pts', style: const TextStyle(color: Colors.greenAccent)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    onPressed: () => _showEditUserDialog(context, user, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      String uName = user['username'];
                      setState(() {
                        AppData.allUsers.removeAt(index);
                      });
                      try {
                        await FirebaseFirestore.instance.collection('users').doc(uName).delete();
                      } catch (e) {
                        print('Firestore Delete Error: $e');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မန်ဘာ အကောင့် ဖျက်ပြီးပါပြီ')));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '10000');
    final pointsCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF132E1B),
          title: const Text('မန်ဘာအသစ် ထည့်သွင်းရန်', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username အသစ်')),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password အသစ်')),
              TextField(controller: balanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'စတင်ရန် လက်ကျန်ငွေ')),
              TextField(controller: pointsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'စတင်ရန် ပွိုင့်')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('မလုပ်ပါ။', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                String newU = userCtrl.text.trim();
                String newP = passCtrl.text.trim();
                double newBalance = double.tryParse(balanceCtrl.text) ?? 10000.0;
                int newPoints = int.tryParse(pointsCtrl.text) ?? 100;

                if (newU.isNotEmpty && newP.isNotEmpty) {
                  setState(() {
                    AppData.allUsers.add({
                      'username': newU,
                      'password': newP,
                      'balance': newBalance,
                      'points': newPoints,
                      'displayName': newU,
                    });
                  });

                  try {
                    await FirebaseFirestore.instance.collection('users').doc(newU).set({
                      'displayName': newU,
                      'password': newP,
                      'balance': newBalance,
                      'points': newPoints,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  } catch (e) {
                    print('Firestore User Save Error: $e');
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မန်ဘာအသစ် အောင်မြင်စွာ ထည့်ပြီး Cloud တွင် သိမ်းဆည်းပြီးပါပြီ')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username နှင့် Password ထည့်ပါ။')));
                }
              },
              child: const Text('ထည့်မည်', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user, int index) {
    final userCtrl = TextEditingController(text: user['username']);
    final passCtrl = TextEditingController(text: user['password']);
    final balanceCtrl = TextEditingController(text: '${user['balance']}');
    final pointsCtrl = TextEditingController(text: '${user['points']}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF132E1B),
          title: Text('ပြင်ဆင်ရန်: ${user['username']}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username')),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password')),
              TextField(controller: balanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'လက်ကျန်ငွေ (Balance)')),
              TextField(controller: pointsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ပွိုင့် (Points)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('မလုပ်ပါ။', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                String oldU = user['username'];
                String newU = userCtrl.text.trim();
                String newP = passCtrl.text.trim();
                double newBalance = double.tryParse(balanceCtrl.text) ?? user['balance'];
                int newPoints = int.tryParse(pointsCtrl.text) ?? user['points'];

                setState(() {
                  AppData.allUsers[index]['username'] = newU;
                  AppData.allUsers[index]['password'] = newP;
                  AppData.allUsers[index]['balance'] = newBalance;
                  AppData.allUsers[index]['points'] = newPoints;

                  if (oldU == AppData.username) {
                    AppData.username = newU;
                    AppData.balance = newBalance;
                    AppData.points = newPoints;
                  }
                });
                
                try {
                  if (oldU != newU) {
                    await FirebaseFirestore.instance.collection('users').doc(oldU).delete();
                  }
                  await FirebaseFirestore.instance.collection('users').doc(newU).set({
                    'displayName': newU,
                    'balance': newBalance,
                    'points': newPoints,
                    'password': newP,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                } catch (e) {
                  print('Firestore User Update Error: $e');
                }

                AppData.saveData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မန်ဘာ အချက်အလက် အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ')));
              },
              child: const Text('သိမ်းမည်', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}

class AdminBetSettlementScreen extends StatefulWidget {
  const AdminBetSettlementScreen({super.key});

  @override
  State<AdminBetSettlementScreen> createState() => _AdminBetSettlementScreenState();
}

class _AdminBetSettlementScreenState extends State<AdminBetSettlementScreen> {
  void _manualSettle(int index, bool isWin) async {
    var bet = AppData.activeBets[index];
    if (bet['status'] != 'ACTIVE') return;

    setState(() {
      if (isWin) {
        bet['status'] = 'WON (အနိုင်ရ)';
        AppData.balance += (bet['potentialWin'] as double);
      } else {
        bet['status'] = 'LOST (အရှုံး)';
      }
    });
    await AppData.saveBetToFirestore(bet);
    await AppData.saveData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('လောင်းကြေး ရလဒ် သတ်မှတ်ပြီးပါပြီ: ${bet['status']}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('လောင်းကြေးများ အနိုင်/အရှုံး စစ်ဆေးရန်'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.greenAccent),
            onPressed: () async {
              await AppData.autoCheckAndSettleBets();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API ဖြင့် အလိုအလျောက် စစ်ဆေးပြီးပါပြီ')));
            },
            tooltip: 'Auto Settle',
          ),
        ],
      ),
      body: AppData.activeBets.isEmpty
          ? const Center(child: Text('လောင်းထားသော ပွဲစဉ်များ မရှိသေးပါ။', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: AppData.activeBets.length,
              itemBuilder: (context, index) {
                var bet = AppData.activeBets[index];
                bool isActive = bet['status'] == 'ACTIVE';

                return Card(
                  color: const Color(0xFF132E1B),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('အမျိုးအစား: ${bet['type']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                            Text(bet['status'], style: TextStyle(color: isActive ? Colors.blue : (bet['status'].toString().contains('WON') ? Colors.green : Colors.red), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('လောင်းငွေ: ${bet['amount']} Ks | ရနိုင်မည့်ငွေ: ${bet['potentialWin']} Ks', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        if (isActive) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(80, 30)),
                                onPressed: () => _manualSettle(index, false),
                                child: const Text('အရှုံး (Loss)', style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(80, 30)),
                                onPressed: () => _manualSettle(index, true),
                                child: const Text('အနိုင် (Win)', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AdminMatchControlScreen extends StatefulWidget {
  const AdminMatchControlScreen({super.key});

  @override
  State<AdminMatchControlScreen> createState() => _AdminMatchControlScreenState();
}

class _AdminMatchControlScreenState extends State<AdminMatchControlScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    await ApiService.fetchMatches();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပွဲစဉ်များနှင့် ကိန်းဂဏန်းများ စီမံရန် (CRUD)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.greenAccent),
            onPressed: () => _showAddMatchDialog(context),
            tooltip: 'ပွဲစဉ်အသစ် ထည့်ရန်',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ApiService.customAdminMatches.isEmpty
              ? const Center(child: Text('ပွဲစဉ်များ မရှိပါ။', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: ApiService.customAdminMatches.length,
                  itemBuilder: (context, index) {
                    var m = ApiService.customAdminMatches[index];
                    var odds = m['odds'] ?? {};
                    return Card(
                      color: const Color(0xFF132E1B),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text('${m['t1']} vs ${m['t2']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('လိဂ်: ${m['league']}\nပွဲချိန်: ${m['time']}\nHome: ${odds['homeOddsText']} | Away: ${odds['awayOddsText']} | Goal: ${odds['goalLineText']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _showEditMatchDialog(context, m, index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () async {
                                setState(() {
                                  ApiService.customAdminMatches.removeAt(index);
                                });
                                await ApiService.saveMatchesToFirestore();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွဲစဉ် ဖျက်ပြီးပါပြီ')));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddMatchDialog(BuildContext context) {
    final t1Ctrl = TextEditingController();
    final t2Ctrl = TextEditingController();
    final leagueCtrl = TextEditingController(text: 'Indonesia Super League');
    final timeCtrl = TextEditingController(text: '14-09-2026, 03:00 pm');
    final homeOddsCtrl = TextEditingController(text: '= -25');
    final awayOddsCtrl = TextEditingController(text: '1.95');
    final goalLineCtrl = TextEditingController(text: '3 +80');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF132E1B),
          title: const Text('ပွဲစဉ်အသစ် ထည့်သွင်းရန်', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: leagueCtrl, decoration: const InputDecoration(labelText: 'လိဂ် အမည်')),
                TextField(controller: t1Ctrl, decoration: const InputDecoration(labelText: 'အိမ်ရှင် အသင်း')),
                TextField(controller: t2Ctrl, decoration: const InputDecoration(labelText: 'ဧည့်သည် အသင်း')),
                TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'ပွဲချိန် (DD-MM-YYYY, HH:MM pm/am)')),
                TextField(controller: homeOddsCtrl, decoration: const InputDecoration(labelText: 'အိမ်ကွင်း ကိန်းဂဏန်း (ဥပမာ - = -25)')),
                TextField(controller: awayOddsCtrl, decoration: const InputDecoration(labelText: 'အဝေးကွင်း ကိန်းဂဏန်း (ဥပမာ - 1.95)')),
                TextField(controller: goalLineCtrl, decoration: const InputDecoration(labelText: 'ဂိုးလိုင်း ကိန်းဂဏန်း (ဥပမာ - 3 +80)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('မလုပ်ပါ။', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                if (t1Ctrl.text.trim().isNotEmpty && t2Ctrl.text.trim().isNotEmpty) {
                  setState(() {
                    ApiService.customAdminMatches.add({
                      'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      'league': leagueCtrl.text.trim(),
                      'time': timeCtrl.text.trim(),
                      't1': t1Ctrl.text.trim(),
                      't2': t2Ctrl.text.trim(),
                      'status': 'UPCOMING',
                      'odds': {
                        'homeOddsText': homeOddsCtrl.text.trim(),
                        'awayOddsText': awayOddsCtrl.text.trim(),
                        'goalLineText': goalLineCtrl.text.trim(),
                        'overOdds': 1.90,
                        'underOdds': 1.85,
                      }
                    });
                  });
                  await ApiService.saveMatchesToFirestore();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွဲစဉ်အသစ် အောင်မြင်စွာ ထည့်ပြီးပါပြီ')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('အသင်းနာမည်များ ထည့်သွင်းပေးပါ။')));
                }
              },
              child: const Text('ထည့်မည်', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _showEditMatchDialog(BuildContext context, Map<String, dynamic> match, int index) {
    final leagueController = TextEditingController(text: match['league']);
    final t1Controller = TextEditingController(text: match['t1']);
    final t2Controller = TextEditingController(text: match['t2']);
    final timeController = TextEditingController(text: match['time']);
    final homeOddsController = TextEditingController(text: match['odds']['homeOddsText']);
    final awayOddsController = TextEditingController(text: match['odds']['awayOddsText']);
    final goalLineController = TextEditingController(text: match['odds']['goalLineText']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF132E1B),
          title: const Text('ပွဲစဉ်နှင့် ကိန်းဂဏန်းများ ပြင်ဆင်ရန်', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: leagueController, decoration: const InputDecoration(labelText: 'လိဂ် အမည်')),
                TextField(controller: t1Controller, decoration: const InputDecoration(labelText: 'အိမ်ရှင် အသင်း')),
                TextField(controller: t2Controller, decoration: const InputDecoration(labelText: 'ဧည့်သည် အသင်း')),
                TextField(controller: timeController, decoration: const InputDecoration(labelText: 'ပွဲချိန်')),
                TextField(controller: homeOddsController, decoration: const InputDecoration(labelText: 'အိမ်ကွင်း ကိန်းဂဏန်း')),
                TextField(controller: awayOddsController, decoration: const InputDecoration(labelText: 'အဝေးကွင်း ကိန်းဂဏန်း')),
                TextField(controller: goalLineController, decoration: const InputDecoration(labelText: 'ဂိုးလိုင်း ကိန်းဂဏန်း')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('မလုပ်ပါ။', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                setState(() {
                  ApiService.customAdminMatches[index]['league'] = leagueController.text.trim();
                  ApiService.customAdminMatches[index]['t1'] = t1Controller.text.trim();
                  ApiService.customAdminMatches[index]['t2'] = t2Controller.text.trim();
                  ApiService.customAdminMatches[index]['time'] = timeController.text.trim();
                  ApiService.customAdminMatches[index]['odds']['homeOddsText'] = homeOddsController.text.trim();
                  ApiService.customAdminMatches[index]['odds']['awayOddsText'] = awayOddsController.text.trim();
                  ApiService.customAdminMatches[index]['odds']['goalLineText'] = goalLineController.text.trim();
                });
                await ApiService.saveMatchesToFirestore();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွဲစဉ် အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ')));
              },
              child: const Text('သိမ်းမည်', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AppData.autoCheckAndSettleBets().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    double totalActiveBetsAmount = 0.0;
    for (var b in AppData.activeBets) {
      if (b['status'] == 'ACTIVE') {
        totalActiveBetsAmount += (b['amount'] as double);
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.sports_soccer, color: Colors.amberAccent),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_football, color: Colors.greenAccent, size: 20),
            SizedBox(width: 6),
            Text('Hat Trick', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF132E1B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(AppData.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              accountEmail: Text('Username: ${AppData.username}', style: const TextStyle(color: Colors.amberAccent)),
              currentAccountPicture: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.sports_soccer, color: Colors.white, size: 32)),
              decoration: const BoxDecoration(color: Color(0xFF0D1B12)),
              otherAccountsPictures: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amberAccent),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
                        .then((_) => _refresh());
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.greenAccent),
              title: Text(AppStrings.get('terms'), style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.greenAccent),
              title: Text(AppStrings.get('changePass'), style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.greenAccent),
              title: Text(AppStrings.get('teamName'), style: const TextStyle(color: Colors.white)),
              trailing: Text(AppData.selectedTeam.contains('မြန်မာ') ? '🇲🇲' : '🌐', style: const TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pop(context);
                _showTeamSelectionDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.greenAccent),
              title: Text(AppStrings.get('language'), style: const TextStyle(color: Colors.white)),
              trailing: Text(AppData.selectedLanguage == 'မြန်မာ' ? '🇲🇲' : '🇬🇧', style: const TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pop(context);
                _showLanguageSelectionDialog(context);
              },
            ),
            const Divider(color: Colors.green),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(AppStrings.get('logout'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                await AppData.clearData();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage('https://images.unsplash.com/photo-1518091043644-c1d4457512c6?q=80&w=1000&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('ငှက်နာမည် မှန်ကန်တူညီမှသာ ထုတ်ယူ၍ရနိုင်ပါမည်', style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF132E1B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade700),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.get('balance'), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(AppStrings.get('points'), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(width: 4),
                                const Icon(Icons.star, color: Colors.amberAccent, size: 14),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('${AppData.points}', style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.green, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.get('betAmount'), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        Text('${totalActiveBetsAmount.toStringAsFixed(1)} Ks', style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _buildMenuCard(context, AppStrings.get('parlay'), Icons.sports_score, Colors.greenAccent, const BettingScreen(isParlay: true)),
                  _buildMenuCard(context, AppStrings.get('single'), Icons.sports_soccer, Colors.amberAccent, const BettingScreen(isParlay: false)),
                  _buildMenuCard(context, AppStrings.get('myBets'), Icons.receipt_long, Colors.orangeAccent, const MyBetsScreen()),
                  _buildMenuCard(context, AppStrings.get('oldMatches'), Icons.calendar_today, Colors.purpleAccent, const OldMatchesScreen()),
                  _buildMenuCard(context, AppStrings.get('wallet'), Icons.account_balance_wallet, Colors.tealAccent, const WalletScreen()),
                  _buildMenuCard(context, AppStrings.get('results'), Icons.live_tv, Colors.amber, const FinishedResultsScreen()),
                  _buildMenuCard(context, AppStrings.get('standings'), Icons.emoji_events, Colors.indigoAccent, const StandingsScreen()),
                  _buildMenuCard(context, AppStrings.get('exchange'), Icons.monetization_on, Colors.lightGreenAccent, const PointsExchangeScreen()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeamSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF132E1B),
          title: const Text('အသင်း/အမည် ရွေးချယ်ရန်', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('မြန်မာ (Myanmar)', style: TextStyle(color: Colors.white)),
                trailing: AppData.selectedTeam == 'မြန်မာ (Myanmar)' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  setState(() { AppData.selectedTeam = 'မြန်မာ (Myanmar)'; });
                  await AppData.saveData();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('ကမ္ဘာ့အသင်းများ (Global Teams)', style: TextStyle(color: Colors.white)),
                trailing: AppData.selectedTeam == 'ကမ္ဘာ့အသင်းများ (Global Teams)' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  setState(() { AppData.selectedTeam = 'ကမ္ဘာ့အသင်းများ (Global Teams)'; });
                  await AppData.saveData();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF132E1B),
          title: const Text('ဘာသာစကား ရွေးချယ်ရန် / Select Language', style: TextStyle(color: Colors.white, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('မြန်မာ (Myanmar)', style: TextStyle(color: Colors.white)),
                trailing: AppData.selectedLanguage == 'မြန်မာ' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  HatTrickApp.setLocale(context, 'မြန်မာ');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English', style: TextStyle(color: Colors.white)),
                trailing: AppData.selectedLanguage == 'English' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  HatTrickApp.setLocale(context, 'English');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget targetScreen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        ).then((_) => _refresh());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF132E1B).withOpacity(0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: AppData.displayName);

  void _updateProfile() async {
    setState(() { AppData.displayName = _nameController.text; });
    await AppData.saveData();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပရိုဖိုင် အချက်အလက်များ သိမ်းဆည်းပြီးပါပြီ')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပရိုဖိုင် စီမံရန်')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'အမည်ပြောင်းရန်', filled: true, fillColor: Color(0xFF132E1B))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _updateProfile,
                child: const Text('အချက်အလက် သိမ်းမည်', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('terms'))),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Hat Trick ၏ စည်းကမ်းသတ်မှတ်ချက်များ -\n\n1. အကောင့်ဖွင့်လှစ်သူများသည် အချက်အလက် အမှန်အကန် ပေးရမည်။\n2. မောင်းလောင်းရာတွင် အနည်းဆုံး ၂ သင်းမှ အများဆုံး ၁၅ သင်းအထိ လောင်းခွင့်ရှိသည်။', style: TextStyle(color: Colors.white, height: 1.5)),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();

  void _changePassword() async {
    if (_newPassController.text.isNotEmpty) {
      for (var u in AppData.allUsers) {
        if (u['username'] == AppData.username) {
          u['password'] = _newPassController.text;
        }
      }

      try {
        await FirebaseFirestore.instance.collection('users').doc(AppData.username).set({
          'password': _newPassController.text,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Password Update Error: $e');
      }

      await AppData.saveData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('စကားဝှက် အောင်မြင်စွာ ပြောင်းလဲပြီးပါပြီ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('စကားဝှက်အသစ် ထည့်ပါ။')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('changePass'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _oldPassController, obscureText: true, decoration: const InputDecoration(labelText: 'စကားဝှက်ဟောင်း', filled: true, fillColor: Color(0xFF132E1B))),
            const SizedBox(height: 16),
            TextField(controller: _newPassController, obscureText: true, decoration: const InputDecoration(labelText: 'စကားဝှက်အသစ်', filled: true, fillColor: Color(0xFF132E1B))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _changePassword,
                child: const Text('ပြောင်းလဲမည်', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BettingScreen extends StatefulWidget {
  final bool isParlay; 
  const BettingScreen({super.key, required this.isParlay});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  late Future<List<Map<String, dynamic>>> _matchesFuture;
  Map<String, dynamic>? _selectedSingleBet;
  final TextEditingController _singleAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _matchesFuture = ApiService.fetchMatches();
  }

  void _handleSelection(Map<String, dynamic> match, String betType, String selection, double odds, {String? lineVal}) {
    if (widget.isParlay) {
      setState(() {
        bool alreadyExists = AppData.parlaySlip.any(
          (item) => item['matchId'] == match['id'] && item['betType'] == betType && item['selection'] == selection
        );
        AppData.parlaySlip.removeWhere((item) => item['matchId'] == match['id']);
        if (!alreadyExists) {
          AppData.parlaySlip.add({
            'matchId': match['id'],
            'matchName': '${match['t1']} vs ${match['t2']}',
            'matchTime': match['time'],
            'betType': betType,
            'selection': selection,
            'odds': odds,
            'lineVal': lineVal ?? '',
          });
        }
      });
    } else {
      setState(() {
        if (_selectedSingleBet != null &&
            _selectedSingleBet!['matchId'] == match['id'] &&
            _selectedSingleBet!['betType'] == betType &&
            _selectedSingleBet!['selection'] == selection) {
          _selectedSingleBet = null;
        } else {
          _selectedSingleBet = {
            'matchId': match['id'],
            'matchName': '${match['t1']} vs ${match['t2']}',
            'matchTime': match['time'],
            'betType': betType,
            'selection': selection,
            'odds': odds,
            'lineVal': lineVal ?? '',
          };
          _showSingleBetBottomSheet();
        }
      });
    }
  }

  bool _isSelected(String matchId, String betType, String selection) {
    if (widget.isParlay) {
      return AppData.parlaySlip.any(
        (item) => item['matchId'] == matchId && item['betType'] == betType && item['selection'] == selection
      );
    } else {
      return _selectedSingleBet != null &&
          _selectedSingleBet!['matchId'] == matchId &&
          _selectedSingleBet!['betType'] == betType &&
          _selectedSingleBet!['selection'] == selection;
    }
  }

  void _showSingleBetBottomSheet() {
    if (_selectedSingleBet == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF132E1B),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double amount = double.tryParse(_singleAmountController.text) ?? 0.0;
            double potentialWin = amount * (_selectedSingleBet!['odds'] as double);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ဘော်ဒီ/ဂိုးပေါင်း (Single)', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('ပွဲစဉ်: ${_selectedSingleBet!['matchName']}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  Text('ပွဲချိန်: ${_selectedSingleBet!['matchTime']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text('ရွေးချယ်မှု: ${_selectedSingleBet!['betType']} (${_selectedSingleBet!['selection']}) [Line: ${_selectedSingleBet!['lineVal']}] | Odds: ${_selectedSingleBet!['odds']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _singleAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setModalState(() {}),
                    decoration: InputDecoration(labelText: 'လောင်းမည့် ငွေပမာဏ (Ks)', filled: true, fillColor: const Color(0xFF0D1B12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 8),
                  Text('အနိုင်ရမည့်ငွေ: ${potentialWin.toStringAsFixed(0)} Ks', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () async {
                        if (amount <= 0 || AppData.balance < amount) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ငွေပမာဏ သို့မဟုတ် လက်ကျန်ငွေ မလုံလောက်ပါ။')));
                          return;
                        }

                        var newBet = {
                          'betId': '${DateTime.now().millisecondsSinceEpoch}',
                          'type': 'ဘော်ဒီ/ဂိုးပေါင်း (Single)',
                          'matches': [_selectedSingleBet],
                          'amount': amount,
                          'totalOdds': _selectedSingleBet!['odds'],
                          'potentialWin': potentialWin,
                          'status': 'ACTIVE',
                        };

                        setState(() {
                          AppData.balance -= amount;
                          AppData.activeBets.add(newBet);
                          _selectedSingleBet = null;
                        });

                        await AppData.saveBetToFirestore(newBet);
                        await AppData.saveData();

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လောင်းခြင်း အောင်မြင်ပါသည်။')));
                      },
                      child: const Text('အတည်ပြုမည်', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isParlay ? AppStrings.get('parlay') : AppStrings.get('single')),
        actions: [
          if (widget.isParlay)
            IconButton(
              icon: Badge(
                label: Text('${AppData.parlaySlip.length}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ParlaySlipScreen()))
                    .then((_) => setState(() {}));
              },
            )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ပွဲစဉ်များ ရယူ၍မရပါ။', style: TextStyle(color: Colors.grey)));
          }

          final matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final m = matches[index];
              final odds = m['odds'];
              String homeOddsText = odds['homeOddsText'] ?? '= -25';
              String awayOddsText = odds['awayOddsText'] ?? '1.95';
              String goalLineText = odds['goalLineText'] ?? '3 +80';

              bool isHomeSelected = _isSelected(m['id'], 'အနိုင်/အရှုံး', m['t1']);
              bool isAwaySelected = _isSelected(m['id'], 'အနိုင်/အရှုံး', m['t2']);
              bool isOverSelected = _isSelected(m['id'], 'ဂိုးပေါင်း (Over/Under)', 'ဂိုးပေါ် (Over)');
              bool isUnderSelected = _isSelected(m['id'], 'ဂိုးပေါင်း (Over/Under)', 'ဂိုးအောက် (Under)');

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF132E1B).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade800),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m['league'], style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('ပွဲချိန် : ${m['time']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'အနိုင်/အရှုံး', m['t1'], 1.85, lineVal: homeOddsText),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(color: isHomeSelected ? Colors.amber : const Color(0xFF1A3D25), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(m['t1'], style: TextStyle(color: isHomeSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  Text(homeOddsText, style: TextStyle(color: isHomeSelected ? Colors.black : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'အနိုင်/အရှုံး', m['t2'], 1.95, lineVal: awayOddsText),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(color: isAwaySelected ? Colors.amber : const Color(0xFF1A3D25), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(m['t2'], style: TextStyle(color: isAwaySelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis, textAlign: TextAlign.end)),
                                  Text(awayOddsText, style: TextStyle(color: isAwaySelected ? Colors.black : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'ဂိုးပေါင်း (Over/Under)', 'ဂိုးပေါ် (Over)', (odds['overOdds'] as num).toDouble(), lineVal: goalLineText),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(color: isOverSelected ? Colors.amber : const Color(0xFF1A3D25), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ဂိုးပေါ်', style: TextStyle(color: isOverSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('${odds['overOdds']}', style: TextStyle(color: isOverSelected ? Colors.black : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(goalLineText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'ဂိုးပေါင်း (Over/Under)', 'ဂိုးအောက် (Under)', (odds['underOdds'] as num).toDouble(), lineVal: goalLineText),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(color: isUnderSelected ? Colors.amber : const Color(0xFF1A3D25), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ဂိုးအောက်', style: TextStyle(color: isUnderSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('${odds['underOdds']}', style: TextStyle(color: isUnderSelected ? Colors.black : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ParlaySlipScreen extends StatefulWidget {
  const ParlaySlipScreen({super.key});

  @override
  State<ParlaySlipScreen> createState() => _ParlaySlipScreenState();
}

class _ParlaySlipScreenState extends State<ParlaySlipScreen> {
  final TextEditingController _amountController = TextEditingController();

  double _calculateTotalOdds() {
    double total = 1.0;
    for (var item in AppData.parlaySlip) {
      total *= (item['odds'] as double);
    }
    return AppData.parlaySlip.isEmpty ? 0.0 : total;
  }

  void _confirmParlayBet() async {
    if (AppData.parlaySlip.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မောင်းလောင်းရန် အနည်းဆုံး ၂ သင်း ပါရှိရပါမည်။')));
      return;
    }
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0 || AppData.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ငွေပမာဏ သို့မဟုတ် လက်ကျန်ငွေ မမှန်ကန်ပါ။')));
      return;
    }

    double totalOdds = _calculateTotalOdds();
    double potentialWin = amount * totalOdds;

    var newBet = {
      'betId': '${DateTime.now().millisecondsSinceEpoch}',
      'type': 'မောင်း (${AppData.parlaySlip.length} သင်းတွဲ)',
      'matches': List.from(AppData.parlaySlip),
      'amount': amount,
      'totalOdds': totalOdds,
      'potentialWin': potentialWin,
      'status': 'ACTIVE',
    };

    setState(() {
      AppData.balance -= amount;
      AppData.activeBets.add(newBet);
      AppData.parlaySlip.clear();
    });

    await AppData.saveBetToFirestore(newBet);
    await AppData.saveData();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မောင်းလောင်းခြင်း အောင်မြင်ပါသည်။')));
  }

  @override
  Widget build(BuildContext context) {
    double totalOdds = _calculateTotalOdds();

    return Scaffold(
      appBar: AppBar(title: const Text('မောင်းစလစ် (Parlay Slip)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: AppData.parlaySlip.isEmpty
                  ? const Center(child: Text('မောင်းစလစ်ထဲတွင် ပွဲစဉ်များ မရှိသေးပါ။', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: AppData.parlaySlip.length,
                      itemBuilder: (context, index) {
                        final item = AppData.parlaySlip[index];
                        return Card(
                          color: const Color(0xFF132E1B),
                          child: ListTile(
                            title: Text(item['matchName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text('ပွဲချိန်: ${item['matchTime']}\n${item['betType']} (${item['selection']}) [Line: ${item['lineVal']}] | Odds: ${item['odds']}', style: const TextStyle(color: Colors.greenAccent)),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => setState(() => AppData.parlaySlip.removeAt(index)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (AppData.parlaySlip.isNotEmpty) ...[
              Text('စုစုပေါင်း Odds: ${totalOdds.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'လောင်းမည့် ငွေပမာဏ (Ks)', filled: true, fillColor: Color(0xFF0D1B12)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _confirmParlayBet,
                  child: const Text('မောင်းလောင်းမည်', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MyBetsScreen extends StatelessWidget {
  const MyBetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('လောင်းထားသော ပွဲစဉ်များ (My Bets)')),
      body: AppData.activeBets.isEmpty
          ? const Center(child: Text('လောင်းထားသော ပွဲစဉ် မရှိသေးပါ။', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: AppData.activeBets.length,
              itemBuilder: (context, index) {
                var bet = AppData.activeBets[index];
                List matches = bet['matches'];

                return Card(
                  color: const Color(0xFF132E1B),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('အမျိုးအစား: ${bet['type']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(bet['status'], style: TextStyle(color: bet['status'] == 'ACTIVE' ? Colors.blue : (bet['status'].toString().contains('WON') ? Colors.green : Colors.red), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(color: Colors.green),
                        ...matches.map<Widget>((m) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('⚽ ${m['matchName']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('🕒 ပွဲချိန်: ${m['matchTime']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              Text('📌 ရွေးချယ်မှု: ${m['betType']} -> ${m['selection']} [Line: ${m['lineVal']}] (Odds: ${m['odds']})', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                              const SizedBox(height: 4),
                            ],
                          ),
                        )),
                        const Divider(color: Colors.green),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('လောင်းငွေ: ${bet['amount']} Ks', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            Text('စုစုပေါင်း Odds: ${bet['totalOdds']}', style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('ရနိုင်မည့်ငွေ: ${bet['potentialWin']} Ks', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OldMatchesScreen extends StatefulWidget {
  const OldMatchesScreen({super.key});

  @override
  State<OldMatchesScreen> createState() => _OldMatchesScreenState();
}

class _OldMatchesScreenState extends State<OldMatchesScreen> {
  String? _selectedDateFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပွဲစဉ်ဟောင်းများ (Match History)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.amberAccent),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                String formatted = "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                setState(() {
                  _selectedDateFilter = formatted;
                });
              }
            },
            tooltip: 'ရက်စွဲအလိုက် ရွေးရန် (Calendar)',
          ),
          if (_selectedDateFilter != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.redAccent),
              onPressed: () => setState(() => _selectedDateFilter = null),
              tooltip: 'စစ်ထုတ်မှု ဖြုတ်ရန်',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedDateFilter != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green.shade900.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ရွေးချယ်ထားသော ရက်စွဲ: ', style: TextStyle(color: Colors.grey)),
                  Text(_selectedDateFilter!, style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.fetchOldMatches(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var list = snapshot.data!;

                if (_selectedDateFilter != null) {
                  list = list.where((m) => m['date'] == _selectedDateFilter).toList();
                }

                if (list.isEmpty) {
                  return const Center(child: Text('ဤရက်စွဲအတွက် ပွဲစဉ်ဟောင်းများ မရှိပါ။', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    var m = list[index];
                    return Card(
                      color: const Color(0xFF132E1B),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.sports_soccer, color: Colors.amberAccent),
                        title: Text(m['match'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${m['league']} | ရက်စွဲ: ${m['date']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        trailing: Text(m['score'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FinishedResultsScreen extends StatelessWidget {
  const FinishedResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OldMatchesScreen();
  }
}

class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('အဆင့်ဇယား')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.fetchStandings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              var s = list[index];
              return ListTile(
                leading: Text('${s['pos']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                title: Text(s['team'], style: const TextStyle(color: Colors.white)),
                trailing: Text('${s['points']} Pts', style: const TextStyle(color: Colors.greenAccent)),
              );
            },
          );
        },
      ),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ငွေစာရင်း')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('လက်ကျန်ငွေစုစုပေါင်း: ${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class PointsExchangeScreen extends StatefulWidget {
  const PointsExchangeScreen({super.key});

  @value:
  @override
  State<PointsExchangeScreen> createState() => _PointsExchangeScreenState();
}

class _PointsExchangeScreenState extends State<PointsExchangeScreen> {
  void _exchange() async {
    if (AppData.points >= 100) {
      setState(() {
        AppData.points -= 100;
        AppData.balance += 1000.0;
      });
      await AppData.saveData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် ၁၀၀ ကို ငွေကျပ် ၁၀၀၀ သို့ လဲလှယ်ပြီးပါပြီ')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် မလုံလောက်ပါ။')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွိုင့်လဲလှယ်')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('လက်ရှိ ပွိုင့်: ${AppData.points} Pts', style: const TextStyle(fontSize: 20, color: Colors.amber)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: _exchange,
              child: const Text('ပွိုင့်လဲမည် (100 Pts = 1000 Ks)', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
