import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('Firebase Init Error: $e');
  }

  await AppData.loadData();
  runApp(const HatTrickApp());
}

// ဘာသာစကား စီမံခန့်ခွဲမှုအတွက် Localization Helper
class AppStrings {
  static Map<String, Map<String, String>> localizedValues = {
    'မြန်မာ': {
      'appTitle': '555SPORT',
      'balance': 'လက်ကျန်ငွေ',
      'points': 'လက်ဆောင် ပွိုင့်များ',
      'betAmount': 'လောင်းထားသောငွေ',
      'parlay': 'မောင်း',
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
      'appTitle': '555SPORT',
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
      title: '555SPORT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class ApiService {
  static const String apiKey = '5a87133d1c764efb8525d81e82d605fd'; 
  static const String baseUrl = 'https://api.football-data.org/v4/matches';

  static List<Map<String, dynamic>> customAdminMatches = [];

  static Future<List<Map<String, dynamic>>> fetchMatches() async {
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
        List matches = data['matches'];
        
        for (var m in matches) {
          String rawTime = m['utcDate'] != null ? m['utcDate'].toString() : '2026-09-13T20:00:00Z';
          String formattedTime = _formatTimeToAMPM(rawTime);

          allMatches.add({
            'id': '${m['id']}',
            'league': m['competition']['name'] ?? 'League',
            'time': formattedTime,
            't1': m['homeTeam']['name'] ?? 'Home Team',
            't2': m['awayTeam']['name'] ?? 'Away Team',
            'status': m['status'] ?? 'UPCOMING',
            'odds': {
              'homeWin': 1.85,
              'awayWin': 1.95,
              'centerVal': '0.5', // အိမ်ကွင်း / အဝေးကွင်း အလယ် ကိန်းဂဏန်းအကွက်
              'goalLine': 2.5,   // ဂိုးပေါ် / ဂိုးအောက် အလယ် ကိန်းဂဏန်းအကွက်
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
          'league': 'English Premier League',
          'time': '08:00 PM',
          't1': 'မန်ချက်စတာစီးတီး',
          't2': 'အာဆင်နယ်',
          'status': 'UPCOMING',
          'odds': {'homeWin': 1.80, 'awayWin': 2.05, 'centerVal': '0/0.5', 'goalLine': 2.5, 'overOdds': 1.85, 'underOdds': 1.90}
        },
        {
          'id': 'auto_m2',
          'league': 'Spanish La Liga',
          'time': '10:30 PM',
          't1': 'ရီးရဲမက်ဒရิด',
          't2': 'ဘာစီလိုနာ',
          'status': 'UPCOMING',
          'odds': {'homeWin': 1.90, 'awayWin': 1.95, 'centerVal': '0.5', 'goalLine': 3.0, 'overOdds': 1.75, 'underOdds': 2.00}
        },
      ]);
    }

    customAdminMatches = allMatches;
    return allMatches;
  }

  static String _formatTimeToAMPM(String utcDateStr) {
    try {
      DateTime dt = DateTime.parse(utcDateStr).toLocal();
      int hour = dt.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;
      String minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (e) {
      return '08:00 PM';
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
        List matches = data['matches'];
        for (var m in matches) {
          final score = m['score']['fullTime'];
          oldMatches.add({
            'matchId': '${m['id']}',
            'league': m['competition']['name'] ?? 'League',
            'match': '${m['homeTeam']['name']} vs ${m['awayTeam']['name']}',
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
      oldMatches.add({
        'matchId': 'm_sample_1',
        'league': 'English Premier League',
        'match': 'မန်ချက်စတာယူနိုက်တက် vs လီဗာပူး',
        'homeScore': 2,
        'awayScore': 1,
        'score': '2 - 1',
        'date': '2026-09-12',
        'result': 'ပြီးဆုံး (FT)',
      });
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
        var table = data['standings'][0]['table'];
        for (var row in table) {
          standings.add({
            'pos': row['position'],
            'team': row['team']['name'],
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

  // တရားဝင် မန်ဘာ (၁၀၀) စာရင်း
  static List<Map<String, String>> authorizedMembers = List.generate(100, (index) {
    int id = index + 1;
    return {
      'username': 'member$id',
      'password': 'pass$id',
    };
  });

  // Admin မှ ဝင်ရောက်စီမံရန် မန်ဘာများစာရင်း အသေးစိတ် (Full CRUD)
  static List<Map<String, dynamic>> allUsers = List.generate(100, (index) {
    int id = index + 1;
    return {
      'username': 'member$id',
      'password': 'pass$id',
      'balance': 10000.0 * (index % 5 + 1),
      'points': 100 * (index % 3 + 1),
    };
  });

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    selectedTeam = prefs.getString('selectedTeam') ?? 'မြန်မာ (Myanmar)';
    selectedLanguage = prefs.getString('selectedLanguage') ?? 'မြန်မာ';
    isMaintenanceMode = prefs.getBool('isMaintenanceMode') ?? false;

    try {
      if (username.isNotEmpty && username != '999admin') {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(username).get();
        if (userDoc.exists) {
          var data = userDoc.data()!;
          balance = (data['balance'] ?? 0.0).toDouble();
          points = data['points'] ?? 0;
          displayName = data['displayName'] ?? username;
        }
      }
    } catch (e) {
      print('Cloud Firestore Load Error: $e');
    }
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('selectedTeam', selectedTeam);
    await prefs.setString('selectedLanguage', selectedLanguage);
    await prefs.setBool('isMaintenanceMode', isMaintenanceMode);

    try {
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
            double line = m['goalLine'] ?? 2.5;
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
        }
      }
      await saveData();
    } catch (e) {
      print('Auto Settle Error: $e');
    }
  }
}

// -------------------------------------------------------------------------
// Login Screen
// -------------------------------------------------------------------------
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

      bool isValidMember = AppData.authorizedMembers.any(
        (member) => member['username'] == uName && member['password'] == pass
      );

      if (!isValidMember) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('အသုံးပြုသူအမည် သို့မဟုတ် စကားဝှက် မမှန်ကန်ပါ (သို့မဟုတ်) အခွင့်အရေးမရှိပါ။')),
        );
        return;
      }

      AppData.isAdmin = false;
      AppData.username = uName;
      AppData.displayName = uName;

      var matchedUser = AppData.allUsers.firstWhere((element) => element['username'] == uName);
      AppData.balance = matchedUser['balance'];
      AppData.points = matchedUser['points'];

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('555SPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
              const SizedBox(height: 8),
              const Text('နည်းနည်းလောင်း များများနိုင်', style: TextStyle(color: Colors.greenAccent, fontSize: 14)),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: 'အသုံးပြုသူ အမည် (Member 1 to 100)',
                  prefixIcon: const Icon(Icons.person, color: Colors.greenAccent),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'စကားဝှက်',
                  prefixIcon: const Icon(Icons.lock, color: Colors.greenAccent),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _login,
                  child: const Text('အကောင့်ဝင်မည်', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Admin Master Control Panel
// -------------------------------------------------------------------------
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
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              AppData.isAdmin = false;
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
            color: const Color(0xFF1F1F1F),
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
            color: const Color(0xFF1F1F1F),
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
            color: const Color(0xFF1F1F1F),
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
            color: const Color(0xFF1F1F1F),
            child: ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.indigoAccent),
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

// -------------------------------------------------------------------------
// Admin Member Management Screen (Full CRUD)
// -------------------------------------------------------------------------
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
            color: const Color(0xFF1F1F1F),
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
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        String uName = user['username'];
                        AppData.allUsers.removeAt(index);
                        AppData.authorizedMembers.removeWhere((m) => m['username'] == uName);
                      });
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
          backgroundColor: const Color(0xFF1F1F1F),
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
              onPressed: () {
                String newU = userCtrl.text.trim();
                String newP = passCtrl.text.trim();
                if (newU.isNotEmpty && newP.isNotEmpty) {
                  setState(() {
                    AppData.authorizedMembers.add({'username': newU, 'password': newP});
                    AppData.allUsers.add({
                      'username': newU,
                      'password': newP,
                      'balance': double.tryParse(balanceCtrl.text) ?? 10000.0,
                      'points': int.tryParse(pointsCtrl.text) ?? 100,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မန်ဘာအသစ် အောင်မြင်စွာ ထည့်ပြီးပါပြီ')));
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
          backgroundColor: const Color(0xFF1F1F1F),
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
              onPressed: () {
                String oldU = user['username'];
                String newU = userCtrl.text.trim();
                String newP = passCtrl.text.trim();

                setState(() {
                  AppData.allUsers[index]['username'] = newU;
                  AppData.allUsers[index]['password'] = newP;
                  AppData.allUsers[index]['balance'] = double.tryParse(balanceCtrl.text) ?? user['balance'];
                  AppData.allUsers[index]['points'] = int.tryParse(pointsCtrl.text) ?? user['points'];

                  int authIndex = AppData.authorizedMembers.indexWhere((m) => m['username'] == oldU);
                  if (authIndex != -1) {
                    AppData.authorizedMembers[authIndex] = {'username': newU, 'password': newP};
                  }

                  if (oldU == AppData.username) {
                    AppData.username = newU;
                    AppData.balance = AppData.allUsers[index]['balance'];
                    AppData.points = AppData.allUsers[index]['points'];
                  }
                });
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

// -------------------------------------------------------------------------
// Admin Bet Settlement Screen
// -------------------------------------------------------------------------
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
                  color: const Color(0xFF1F1F1F),
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
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(80, 30)),
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

// -------------------------------------------------------------------------
// Admin Match Control Screen (CRUD)
// -------------------------------------------------------------------------
class AdminMatchControlScreen extends StatefulWidget {
  const AdminMatchControlScreen({super.key});

  @override
  State<AdminMatchControlScreen> createState() => _AdminMatchControlScreenState();
}

class _AdminMatchControlScreenState extends State<AdminMatchControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပွဲစဉ်များ စီမံရန် (CRUD)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.greenAccent),
            onPressed: () => _showAddMatchDialog(context),
            tooltip: 'ပွဲစဉ်အသစ် ထည့်ရန်',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.fetchMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ပွဲစဉ်များ မရှိပါ။'));
          }

          var matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              var m = matches[index];
              var odds = m['odds'];
              return Card(
                color: const Color(0xFF1F1F1F),
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('${m['t1']} vs ${m['t2']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('League: ${m['league']} | Time: ${m['time']} | Handicap: ${odds['centerVal']} | Line: ${odds['goalLine']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => _showEditMatchDialog(context, m, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            ApiService.customAdminMatches.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွဲစဉ် ဖျက်ပြီးပါပြီ')));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddMatchDialog(BuildContext context) {
    final t1Ctrl = TextEditingController();
    final t2Ctrl = TextEditingController();
    final leagueCtrl = TextEditingController(text: 'English Premier League');
    final timeCtrl = TextEditingController(text: '08:00 PM');
    final centerValCtrl = TextEditingController(text: '0.5');
    final goalLineCtrl = TextEditingController(text: '2.5');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          title: const Text('ပွဲစဉ်အသစ် ထည့်သွင်းရန်', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: leagueCtrl, decoration: const InputDecoration(labelText: 'လိဂ် အမည်')),
                TextField(controller: t1Ctrl, decoration: const InputDecoration(labelText: 'အိမ်ရှင် အသင်း')),
                TextField(controller: t2Ctrl, decoration: const InputDecoration(labelText: 'ဧည့်သည် အသင်း')),
                TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'ပွဲချိန် (AM/PM)')),
                TextField(controller: centerValCtrl, decoration: const InputDecoration(labelText: 'အိမ်/အဝေး အလယ်ကိန်းဂဏန်း (Handicap)')),
                TextField(controller: goalLineCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ဂိုးလိုင်း ကိန်းဂဏန်း (Goal Line)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('မလုပ်ပါ။', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                setState(() {
                  ApiService.customAdminMatches.add({
                    'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    'league': leagueCtrl.text,
                    'time': timeCtrl.text,
                    't1': t1Ctrl.text,
                    't2': t2Ctrl.text,
                    'status': 'UPCOMING',
                    'odds': {
                      'homeWin': 1.85,
                      'awayWin': 1.95,
                      'centerVal': centerValCtrl.text,
                      'goalLine': double.tryParse(goalLineCtrl.text) ?? 2.5,
                      'overOdds': 1.90,
                      'underOdds': 1.85,
                    }
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွဲစဉ်အသစ် အောင်မြင်စွာ ထည့်ပြီးပါပြီ')));
              },
              child: const Text('ထည့်မည်', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _showEditMatchDialog(BuildContext context, Map<String, dynamic> match, int index) {
    final t1Controller = TextEditingController(text: match['t1']);
    final t2Controller = TextEditingController(text: match['t2']);
    final timeController = TextEditingController(text: match['time']);
    final centerValCtrl = TextEditingController(text: '${match['odds']['centerVal']}');
    final goalLineController = TextEditingController(text: '${match['odds']['goalLine']}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          title: const Text('ပွဲစဉ် ပြင်ဆင်ရန်', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: t1Controller, decoration: const InputDecoration(labelText: 'အိမ်ရှင် အသင်း')),
                TextField(controller: t2Controller, decoration: const InputDecoration(labelText: 'ဧည့်သည် အသင်း')),
                TextField(controller: timeController, decoration: const InputDecoration(labelText: 'ပွဲချိန် (AM/PM)')),
                TextField(controller: centerValCtrl, decoration: const InputDecoration(labelText: 'အိမ်/အဝေး အလယ်ကိန်းဂဏန်း (Handicap)')),
                TextField(controller: goalLineController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ဂိုးလိုင်း (Goal Line)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('မလုပ်ပါ။', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                setState(() {
                  ApiService.customAdminMatches[index]['t1'] = t1Controller.text;
                  ApiService.customAdminMatches[index]['t2'] = t2Controller.text;
                  ApiService.customAdminMatches[index]['time'] = timeController.text;
                  ApiService.customAdminMatches[index]['odds']['centerVal'] = centerValCtrl.text;
                  ApiService.customAdminMatches[index]['odds']['goalLine'] = double.tryParse(goalLineController.text) ?? 2.5;
                });
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

// -------------------------------------------------------------------------
// User Dashboard
// -------------------------------------------------------------------------
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
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('555', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('SPORT', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2C2C2C),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(AppData.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              accountEmail: Text('Username: ${AppData.username}', style: const TextStyle(color: Colors.grey)),
              currentAccountPicture: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
              decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
              otherAccountsPictures: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.greenAccent),
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
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(AppStrings.get('logout'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.amber.shade900.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
              child: const Text('ငှက်နာမည် မှန်ကန်တူညီမှသာ ထုတ်ယူ၍ရနိုင်ပါမည်', style: TextStyle(color: Colors.amber, fontSize: 12)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade800),
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
                          Text('${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(AppStrings.get('points'), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(width: 4),
                              const Icon(Icons.history, color: Colors.greenAccent, size: 14),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${AppData.points}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.get('betAmount'), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      Text('${totalActiveBetsAmount.toStringAsFixed(1)} Ks', style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold)),
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
                _buildMenuCard(context, AppStrings.get('parlay'), Icons.sports_score, Colors.green, const BettingScreen(isParlay: true)),
                _buildMenuCard(context, AppStrings.get('single'), Icons.sports_soccer, Colors.blue, const BettingScreen(isParlay: false)),
                _buildMenuCard(context, AppStrings.get('myBets'), Icons.receipt_long, Colors.orange, const MyBetsScreen()),
                _buildMenuCard(context, AppStrings.get('oldMatches'), Icons.calendar_today, Colors.purple, const OldMatchesScreen()),
                _buildMenuCard(context, AppStrings.get('wallet'), Icons.account_balance_wallet, Colors.teal, const WalletScreen()),
                _buildMenuCard(context, AppStrings.get('results'), Icons.live_tv, Colors.amber, const FinishedResultsScreen()),
                _buildMenuCard(context, AppStrings.get('standings'), Icons.emoji_events, Colors.indigo, const StandingsScreen()),
                _buildMenuCard(context, AppStrings.get('exchange'), Icons.monetization_on, Colors.lightGreen, const PointsExchangeScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
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
          backgroundColor: const Color(0xFF1F1F1F),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပရိုไฟล์ အချက်အလက်များ သိမ်းဆည်းပြီးပါပြီ')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပရိုไฟล์ စီမံရန်')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'အမည်ပြောင်းရန်', filled: true, fillColor: Color(0xFF1F1F1F))),
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
        child: Text('555SPORT ၏ စည်းကမ်းသတ်မှတ်ချက်များ -\n\n1. အကောင့်ဖွင့်လှစ်သူများသည် အချက်အလက် အမှန်အကန် ပေးရမည်။\n2. မောင်းလောင်းရာတွင် အနည်းဆုံး ၂ သင်းမှ အများဆုံး ၁၅ သင်းအထိ လောင်းခွင့်ရှိသည်။', style: TextStyle(color: Colors.white, height: 1.5)),
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
            TextField(controller: _oldPassController, obscureText: true, decoration: const InputDecoration(labelText: 'စကားဝှက်ဟောင်း', filled: true, fillColor: Color(0xFF1F1F1F))),
            const SizedBox(height: 16),
            TextField(controller: _newPassController, obscureText: true, decoration: const InputDecoration(labelText: 'စကားဝှက်အသစ်', filled: true, fillColor: Color(0xFF1F1F1F))),
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

// -------------------------------------------------------------------------
// Betting Screen (အိမ်ကွင်း/အဝေးကွင်း & ဂိုးပေါ်/ဂိုးအောက် အလယ်ကိန်းဂဏန်းအကွက်များပါဝင်သော UI)
// -------------------------------------------------------------------------
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

  void _handleSelection(Map<String, dynamic> match, String betType, String selection, double odds, {dynamic lineVal}) {
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
      backgroundColor: const Color(0xFF1F1F1F),
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
                  Text('ရွေးချယ်မှု: ${_selectedSingleBet!['betType']} (${_selectedSingleBet!['selection']}) | Odds: ${_selectedSingleBet!['odds']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _singleAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setModalState(() {}),
                    decoration: InputDecoration(labelText: 'လောင်းမည့် ငွေပမာဏ (Ks)', filled: true, fillColor: const Color(0xFF2C2C2C), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
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

                        setState(() {
                          AppData.balance -= amount;
                          AppData.activeBets.add({
                            'betId': '${DateTime.now().millisecondsSinceEpoch}',
                            'type': 'ဘော်ဒီ/ဂိုးပေါင်း (Single)',
                            'matches': [_selectedSingleBet],
                            'amount': amount,
                            'totalOdds': _selectedSingleBet!['odds'],
                            'bonusPct': 0.0,
                            'potentialWin': potentialWin,
                            'status': 'ACTIVE',
                          });
                          _selectedSingleBet = null;
                        });
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
              String centerVal = odds['centerVal'] ?? '0.5';
              double goalLine = odds['goalLine'] ?? 2.5;

              bool isHomeSelected = _isSelected(m['id'], 'အနိုင်/အရှုံး', m['t1']);
              bool isAwaySelected = _isSelected(m['id'], 'အနိုင်/အရှုံး', m['t2']);
              bool isOverSelected = _isSelected(m['id'], 'ဂိုးပေါင်း (Over/Under)', 'ဂိုးပေါ် (Over)');
              bool isUnderSelected = _isSelected(m['id'], 'ဂိုးပေါင်း (Over/Under)', 'ဂိုးအောက် (Under)');

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF1F1F1F), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade800)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // လိဂ်အမည် နှင့် ပွဲချိန် (AM/PM)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m['league'], style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('ပွဲချိန် : ${m['time']}', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // -------------------------------------------------------------
                    // တန်း ၁ : အိမ်ကွင်း အသင်း | အလယ် ကိန်းဂဏန်းအကွက် (Handicap) | အဝေးကွင်း အသင်း
                    // -------------------------------------------------------------
                    Row(
                      children: [
                        // အိမ်ကွင်း
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'အနိုင်/အရှုံး', m['t1'], odds['homeWin'], lineVal: centerVal),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(color: isHomeSelected ? Colors.amber : Colors.grey.shade800, borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(m['t1'], style: TextStyle(color: isHomeSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                  Text('${odds['homeWin']}', style: TextStyle(color: isHomeSelected ? Colors.black : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // အိမ်ကွင်း/အဝေးကွင်း အလယ် ကိန်းဂဏန်းအကွက် (Handicap)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: Text(centerVal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        const SizedBox(width: 4),
                        // အဝေးကွင်း
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'အနိုင်/အရှုံး', m['t2'], odds['awayWin'], lineVal: centerVal),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(color: isAwaySelected ? Colors.amber : Colors.grey.shade800, borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(m['t2'], style: TextStyle(color: isAwaySelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis, textAlign: TextAlign.end)),
                                  Text('${odds['awayWin']}', style: TextStyle(color: isAwaySelected ? Colors.black : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // -------------------------------------------------------------
                    // တန်း ၂ (အိမ်/အဝေး အောက်တွင်) : ဂိုးပေါ် (Over) | အလယ် ဂိုးလိုင်း ကိန်းဂဏန်းအကွက် | ဂိုးအောက် (Under)
                    // -------------------------------------------------------------
                    Row(
                      children: [
                        // ဂိုးပေါ် (Over)
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'ဂိုးပေါင်း (Over/Under)', 'ဂိုးပေါ် (Over)', odds['overOdds'], lineVal: goalLine),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(color: isOverSelected ? Colors.amber : Colors.grey.shade800, borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ဂိုးပေါ် (Over)', style: TextStyle(color: isOverSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                  Text('${odds['overOdds']}', style: TextStyle(color: isOverSelected ? Colors.black : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // ဂိုးပေါ်/ဂိုးအောက် အလယ် ဂိုးလိုင်း ကိန်းဂဏန်းအကွက်
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade900,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber, width: 1),
                          ),
                          child: Text('$goalLine', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        const SizedBox(width: 4),
                        // ဂိုးအောက် (Under)
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'ဂိုးပေါင်း (Over/Under)', 'ဂိုးအောက် (Under)', odds['underOdds'], lineVal: goalLine),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(color: isUnderSelected ? Colors.amber : Colors.grey.shade800, borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ဂိုးအောက် (Under)', style: TextStyle(color: isUnderSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                  Text('${odds['underOdds']}', style: TextStyle(color: isUnderSelected ? Colors.black : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
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

// -------------------------------------------------------------------------
// Parlay Slip Screen (မောင်းစလစ်)
// -------------------------------------------------------------------------
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

    setState(() {
      AppData.balance -= amount;
      AppData.activeBets.add({
        'betId': '${DateTime.now().millisecondsSinceEpoch}',
        'type': 'မောင်း (${AppData.parlaySlip.length} သင်းတွဲ)',
        'matches': List.from(AppData.parlaySlip),
        'amount': amount,
        'totalOdds': totalOdds,
        'potentialWin': potentialWin,
        'status': 'ACTIVE',
      });
      AppData.parlaySlip.clear();
    });
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
                          color: const Color(0xFF1F1F1F),
                          child: ListTile(
                            title: Text(item['matchName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text('${item['betType']} (${item['selection']}) [Line: ${item['lineVal']}] | Odds: ${item['odds']}', style: const TextStyle(color: Colors.greenAccent)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
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
                decoration: const InputDecoration(labelText: 'လောင်းမည့် ငွေပမာဏ (Ks)', filled: true, fillColor: Color(0xFF2C2C2C)),
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
      appBar: AppBar(title: const Text('လောင်းထားသော ပွဲစဉ်များ')),
      body: AppData.activeBets.isEmpty
          ? const Center(child: Text('လောင်းထားသော ပွဲစဉ် မရှိသေးပါ။', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: AppData.activeBets.length,
              itemBuilder: (context, index) {
                var bet = AppData.activeBets[index];
                return Card(
                  color: const Color(0xFF1F1F1F),
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('အမျိုးအစား: ${bet['type']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    subtitle: Text('လောင်းငွေ: ${bet['amount']} Ks | ရနိုင်မည့်ငွေ: ${bet['potentialWin']} Ks', style: const TextStyle(color: Colors.white)),
                    trailing: Text(bet['status'], style: TextStyle(color: bet['status'] == 'ACTIVE' ? Colors.blue : Colors.green, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
    );
  }
}

class OldMatchesScreen extends StatelessWidget {
  const OldMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွဲစဉ်ဟောင်းများ')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.fetchOldMatches(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              var m = list[index];
              return ListTile(
                title: Text(m['match'], style: const TextStyle(color: Colors.white)),
                subtitle: Text(m['league'], style: const TextStyle(color: Colors.grey)),
                trailing: Text(m['score'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              );
            },
          );
        },
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
