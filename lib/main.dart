import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Firebase Background Notification Handler
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
    print('Firebase Init Error (Running offline/local mode): $e');
  }

  await AppData.loadData();
  runApp(const HatTrickApp());
}

class HatTrickApp extends StatefulWidget {
  const HatTrickApp({super.key});

  static void setLocale(BuildContext context, String lang) {
    _HatTrickAppState? state = context.findAncestorStateOfType<_HatTrickAppState>();
    state?.setLocale(lang);
  }

  @override
  State<HatTrickApp> createState() => _HatTrickAppState();
}

class _HatTrickAppState extends State<HatTrickApp> {
  void setLocale(String lang) {
    setState(() {
      AppData.language = lang;
      AppData.saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HAT TRICK - 999',
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

// Localization Text Helper
class AppStrings {
  static Map<String, Map<String, String>> localizedValues = {
    'မြန်မာ': {
      'appName': 'HAT TRICK',
      'appSub': '- 999 -',
      'tagline': 'နည်းနည်းလောင်း များများနိုင်',
      'login': 'အကောင့်ဝင်မည်',
      'username': 'အသုံးပြုသူ အမည်',
      'password': 'စကားဝှက်',
      'balance': 'လက်ကျန်ငွေ',
      'points': 'လက်ဆောင် ပွိုင့်များ',
      'activeBetsAmt': 'လောင်းထားသောငွေ',
      'menuTerms': 'စည်းကမ်းသတ်မှတ်ချက်များ',
      'menuPass': 'စကားဝှက် ပြောင်းရန်',
      'menuTeam': 'အသင်းအမည်',
      'menuLang': 'ဘာသာစကားရွေးရန်',
      'logout': 'ထွက်ရန်',
      'wallet': 'ငွေစာရင်း',
      'myBets': 'လောင်းထားသောပွဲစဉ်များ',
      'oldMatches': 'ပွဲစဉ်ဟောင်းများ',
      'liveResults': 'ပွဲပြီး ရလဒ်များ',
      'standings': 'အဆင့်ဇယား',
      'pointsExchange': 'ပွိုင့်လဲလှယ်',
    },
    'English': {
      'appName': 'HAT TRICK',
      'appSub': '- 999 -',
      'tagline': 'Play Smart, Win Big',
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      'balance': 'Balance',
      'points': 'Reward Points',
      'activeBetsAmt': 'Active Bets Amount',
      'menuTerms': 'Terms & Conditions',
      'menuPass': 'Change Password',
      'menuTeam': 'Team Name',
      'menuLang': 'Language',
      'logout': 'Logout',
      'wallet': 'Wallet',
      'myBets': 'My Bets',
      'oldMatches': 'Old Matches',
      'liveResults': 'Live Results',
      'standings': 'Standings',
      'pointsExchange': 'Points Exchange',
    },
  };

  static String get(String key, String lang) {
    return localizedValues[lang]?[key] ?? localizedValues['မြန်မာ']![key] ?? key;
  }
}

// API Service with Expanded Rich Matches (API + Extra Rich Mock Matches)
class ApiService {
  static const String apiKey = '5a87133d1c764efb8525d81e82d605fd'; 
  static const String baseUrl = 'https://api.football-data.org/v4/matches';

  static Future<List<Map<String, dynamic>>> fetchLiveMatches() async {
    List<Map<String, dynamic>> allMatches = [];

    // 1. Fetch from Real API
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List matches = data['matches'];
        
        for (var m in matches) {
          allMatches.add({
            'league': m['competition']['name'] ?? 'League',
            'time': m['utcDate'] ?? '20:00',
            't1': m['homeTeam']['name'] ?? 'Home',
            'score': '${m['score']['fullTime']['home'] ?? 0} - ${m['score']['fullTime']['away'] ?? 0}',
            't2': m['awayTeam']['name'] ?? 'Away',
            'status': m['status'] ?? 'SCHEDULED',
          });
        }
      }
    } catch (e) {
      print('API Error: $e');
    }

    // 2. Extra Rich Matches to make sure the app always has plenty of matches to bet/view
    List<Map<String, dynamic>> extraMatches = [
      {'league': 'English Premier League', 'time': '21:00', 't1': 'မန်ချက်စတာယူနိုက်တက်', 'score': '0 - 0', 't2': 'လီဗာပူးလ်', 'status': 'SCHEDULED'},
      {'league': 'English Premier League', 'time': '23:30', 't1': 'မန်စီးတီး', 'score': '1 - 0', 't2': 'အာဆင်နယ်', 'status': 'LIVE'},
      {'league': 'Spanish La Liga', 'time': '01:00', 't1': 'ရီးရဲမက်ဒရစ်', 'score': '2 - 1', 't2': 'ဘာစီလိုနာ', 'status': 'LIVE'},
      {'league': 'Italian Serie A', 'time': '20:30', 't1': 'ဂျူဗင်တပ်စ်', 'score': '0 - 0', 't2': 'အေစီမီလန်', 'status': 'SCHEDULED'},
      {'league': 'German Bundesliga', 'time': '19:30', 't1': 'ဘိုင်ယန်မြူးနစ်', 'score': '3 - 1', 't2': 'ဒေါ့မွန်', 'status': 'FINISHED'},
      {'league': 'French Ligue 1', 'time': '22:00', 't1': 'ပီအက်စ်ဂျီ', 'score': '2 - 0', 't2': 'မာဆေးလ်', 'status': 'SCHEDULED'},
      {'league': 'UEFA Champions League', 'time': '02:00', 't1': 'ချယ်ဆီး', 'score': '1 - 1', 't2': 'အက်သလက်တီကို', 'status': 'SCHEDULED'},
      {'league': 'UEFA Champions League', 'time': '02:00', 't1': 'တော့တင်ဟမ်', 'score': '0 - 2', 't2': 'အင်တာမီလန်', 'status': 'SCHEDULED'},
    ];

    // ပုံမှန် API ပွဲတွေအပြင် အပိုပွဲစဉ်များကိုပါ ရောနှောထည့်သွင်းပေးခြင်း
    for (var em in extraMatches) {
      // ထပ်နေတာတွေ မပါအောင် စစ်ပြီး ထည့်မည်
      bool exists = allMatches.any((m) => m['t1'] == em['t1'] && m['t2'] == em['t2']);
      if (!exists) {
        allMatches.add(em);
      }
    }

    return allMatches;
  }
}

// App Data Controller
class AppData {
  static String displayName = 'User';
  static String username = '';
  static String password = '123';
  static String language = 'မြန်မာ';
  static String selectedTeam = 'မြန်မာ';
  
  static double balance = 0.0;
  static int points = 0;
  static double totalActiveBetsAmount = 0.0;

  static List<Map<String, dynamic>> activeBets = [];
  static List<Map<String, dynamic>> walletHistory = [];

  static List<Map<String, dynamic>> standingsList = [
    {'pos': 1, 'team': 'ရီးရဲမက်ဒရစ်', 'p': 5, 'pts': 15},
    {'pos': 2, 'team': 'ဘာစီလိုနာ', 'p': 5, 'pts': 12},
    {'pos': 3, 'team': 'မန်စီးတီး', 'p': 5, 'pts': 11},
    {'pos': 4, 'team': 'လီဗာပူးလ်', 'p': 5, 'pts': 10},
  ];

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    displayName = prefs.getString('displayName') ?? 'User';
    username = prefs.getString('username') ?? '';
    password = prefs.getString('password') ?? '123';
    language = prefs.getString('language') ?? 'မြန်မာ';
    selectedTeam = prefs.getString('selectedTeam') ?? 'မြန်မာ';
    balance = prefs.getDouble('balance') ?? 0.0;
    points = prefs.getInt('points') ?? 0;
    totalActiveBetsAmount = prefs.getDouble('totalActiveBetsAmount') ?? 0.0;
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', displayName);
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setString('language', language);
    await prefs.setString('selectedTeam', selectedTeam);
    await prefs.setDouble('balance', balance);
    await prefs.setInt('points', points);
    await prefs.setDouble('totalActiveBetsAmount', totalActiveBetsAmount);
  }
}

// 1. Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() {
    if (_userController.text.isNotEmpty && _passController.text.isNotEmpty) {
      setState(() {
        AppData.username = _userController.text;
        AppData.displayName = _userController.text;
        AppData.saveData();
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('အသုံးပြုသူအမည်နှင့် စကားဝှက် ထည့်ပါ')),
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
              Text(AppStrings.get('appName', AppData.language), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
              Text(AppStrings.get('appSub', AppData.language), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 26)),
              const SizedBox(height: 8),
              Text(AppStrings.get('tagline', AppData.language), style: const TextStyle(color: Colors.amber, fontSize: 14)),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('username', AppData.language),
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
                  labelText: AppStrings.get('password', AppData.language),
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
                  child: Text(AppStrings.get('login', AppData.language), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _refresh() => setState(() {});

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(AppStrings.get('menuPass', AppData.language), style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPassController, obscureText: true, decoration: const InputDecoration(labelText: 'လက်ရှိ စကားဝှက်')),
            const SizedBox(height: 10),
            TextField(controller: newPassController, obscureText: true, decoration: const InputDecoration(labelText: 'စကားဝှက်အသစ်')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('မလုပ်တော့ပါ', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              if (oldPassController.text == AppData.password) {
                setState(() {
                  AppData.password = newPassController.text;
                  AppData.saveData();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('စကားဝှက် အောင်မြင်စွာ ပြောင်းပြီးပါပြီ')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ရှိ စကားဝှက် မှားယွင်းနေပါသည်။')));
              }
            },
            child: const Text('ပြောင်းမည်', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(AppStrings.get('menuTerms', AppData.language), style: const TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Text(
            '၁။ အသုံးပြုသူများသည် အသက် ၁၈ နှစ်ပြည့်ပြီးသူ ဖြစ်ရပါမည်။\n၂။ ငွေသွင်းငွေထုတ် မှန်ကန်ရမည်။\n၃။ စနစ်၏ ဆုံးဖြတ်ချက်သည် အတည်ဖြစ်ပါသည်။',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  void _showTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(AppStrings.get('menuTeam', AppData.language), style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['မြန်မာ', 'အင်္ဂလိပ်', 'ထိုင်း'].map((team) {
            return ListTile(
              title: Text(team, style: const TextStyle(color: Colors.white)),
              trailing: AppData.selectedTeam == team ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() {
                  AppData.selectedTeam = team;
                  AppData.saveData();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('အသင်းကို $team သို့ ပြောင်းပြီးပါပြီ')));
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(AppStrings.get('menuLang', AppData.language), style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['မြန်မာ', 'English'].map((lang) {
            return ListTile(
              title: Text(lang, style: const TextStyle(color: Colors.white)),
              trailing: AppData.language == lang ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                HatTrickApp.setLocale(context, lang);
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language changed to $lang')));
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.get('appName', AppData.language), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const Text(' - 999', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Text(AppStrings.get('tagline', AppData.language), style: const TextStyle(color: Colors.amber, fontSize: 10)),
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
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.grey),
              title: Text(AppStrings.get('menuTerms', AppData.language), style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showTermsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.grey),
              title: Text(AppStrings.get('menuPass', AppData.language), style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.amber),
              title: Text(AppStrings.get('menuTeam', AppData.language), style: const TextStyle(color: Colors.white)),
              subtitle: Text(AppData.selectedTeam, style: const TextStyle(color: Colors.greenAccent)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showTeamDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: Text(AppStrings.get('menuLang', AppData.language), style: const TextStyle(color: Colors.white)),
              subtitle: Text(AppData.language, style: const TextStyle(color: Colors.greenAccent)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showLanguageDialog();
              },
            ),
            const Divider(color: Colors.grey),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Version 12.0.2', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(AppStrings.get('logout', AppData.language), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.get('balance', AppData.language), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppStrings.get('points', AppData.language), style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
                      Text(AppStrings.get('activeBetsAmt', AppData.language), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('${AppData.totalActiveBetsAmount.toStringAsFixed(1)} Ks', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
                _buildMenuCard(context, 'မောင်း', Icons.sports_score, Colors.green, const BettingScreen(title: 'မောင်း')),
                _buildMenuCard(context, 'ဘော်ဒီ/ဂိုးပေါင်း', Icons.sports_soccer, Colors.blue, const BettingScreen(title: 'ဘော်ဒီ/ဂိုးပေါင်း')),
                _buildMenuCard(context, AppStrings.get('myBets', AppData.language), Icons.receipt_long, Colors.orange, const MyBetsScreen()),
                _buildMenuCard(context, AppStrings.get('oldMatches', AppData.language), Icons.calendar_today, Colors.purple, const OldMatchesScreen()),
                _buildMenuCard(context, AppStrings.get('wallet', AppData.language), Icons.account_balance_wallet, Colors.teal, const WalletScreen()),
                _buildMenuCard(context, AppStrings.get('liveResults', AppData.language), Icons.live_tv, Colors.redAccent, const LiveResultsScreen()),
                _buildMenuCard(context, AppStrings.get('standings', AppData.language), Icons.emoji_events, Colors.amber, const StandingsScreen()),
                _buildMenuCard(context, AppStrings.get('pointsExchange', AppData.language), Icons.monetization_on, Colors.indigo, const PointsExchangeScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget targetScreen) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)).then((_) => _refresh());
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
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}

// 3. Betting Screen
class BettingScreen extends StatefulWidget {
  final String title;
  const BettingScreen({super.key, required this.title});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  final TextEditingController _amountController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _matchesFuture;
  
  Map<String, dynamic>? selectedMatchData;
  String selectedBetType = 'Home Win (1)';

  @override
  void initState() {
    super.initState();
    _matchesFuture = ApiService.fetchLiveMatches();
  }

  void _placeBet() {
    if (selectedMatchData == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ကျေးဇူးပြု၍ လောင်းမည့် ပွဲစဉ်ကို ရွေးချယ်ပါ။')));
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လောင်းငွေ မှန်ကန်စွာ ထည့်ပါ။')));
      return;
    }
    if (AppData.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ကျန်ငွေ မလုံလောက်ပါ။')));
      return;
    }

    String matchStr = "${selectedMatchData!['t1']} vs ${selectedMatchData!['t2']}";

    setState(() {
      AppData.balance -= amount;
      AppData.totalActiveBetsAmount += amount;
      AppData.activeBets.add({
        'betId': '${DateTime.now().millisecondsSinceEpoch}',
        'match': '$matchStr (${widget.title} - $selectedBetType)',
        'amount': amount,
        'odds': 1.90,
        'status': 'ACTIVE',
        'time': '04-09-2026'
      });
      AppData.saveData();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွဲစဉ် လောင်းခြင်း အောင်မြင်ပါသည်။')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} - ပွဲစဉ်များ')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              '${widget.title} အတွက် အောက်ပါပွဲစဉ်များထဲမှ ရွေးချယ်ပါ',
              style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _matchesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('လောလောဆယ် ပွဲစဉ်များ မရှိသေးပါ။', style: TextStyle(color: Colors.grey)));
                  }

                  final matches = snapshot.data!;
                  return ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final m = matches[index];
                      bool isSelected = selectedMatchData == m;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.withOpacity(0.2) : const Color(0xFF1F1F1F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade800),
                        ),
                        child: ListTile(
                          title: Text('${m['t1']} vs ${m['t2']}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text('လိဂ်: ${m['league']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          trailing: Radio<Map<String, dynamic>>(
                            value: m,
                            groupValue: selectedMatchData,
                            activeColor: Colors.greenAccent,
                            onChanged: (val) {
                              setState(() {
                                selectedMatchData = val;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              selectedMatchData = m;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedMatchData != null 
                        ? 'ရွေးထားသောပွဲ: ${selectedMatchData!['t1']} vs ${selectedMatchData!['t2']}' 
                        : 'ပွဲစဉ် မရွေးရသေးပါ',
                      style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'လောင်းမည့် ငွေပမာဏ (Ks)',
                        filled: true,
                        fillColor: const Color(0xFF1F1F1F),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: _placeBet,
                        child: const Text('အတည်ပြု လောင်းမည်', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. My Bets Screen
class MyBetsScreen extends StatelessWidget {
  const MyBetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('myBets', AppData.language))),
      body: AppData.activeBets.isEmpty
          ? const Center(child: Text('လောင်းထားသော ပွဲစဉ် မရှိသေးပါ', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: AppData.activeBets.length,
              itemBuilder: (context, index) {
                final bet = AppData.activeBets[index];
                return Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bet ID: ${bet['betId']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      Text('ပွဲစဉ်: ${bet['match']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('လောင်းငွေ: ${bet['amount']} Ks', style: const TextStyle(color: Colors.greenAccent)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// 5. Old Matches Screen
class OldMatchesScreen extends StatefulWidget {
  const OldMatchesScreen({super.key});

  @override
  State<OldMatchesScreen> createState() => _OldMatchesScreenState();
}

class _OldMatchesScreenState extends State<OldMatchesScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('oldMatches', AppData.language))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ရွေးချယ်ထားသော ရက်စွဲ: $formattedDate', style: const TextStyle(color: Colors.greenAccent, fontSize: 14)),
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('မန်ချက်စတာယူနိုက်တက် vs လီဗာပူးလ်', style: TextStyle(color: Colors.white)),
                    subtitle: Text('ရလဒ်: ၂ - ၁ (FT)', style: TextStyle(color: Colors.greenAccent)),
                    trailing: Icon(Icons.sports_soccer, color: Colors.grey),
                  ),
                  Divider(color: Colors.grey),
                  ListTile(
                    title: Text('ရီးရဲမက်ဒရစ် vs ဘာစီလိုနာ', style: TextStyle(color: Colors.white)),
                    subtitle: Text('ရလဒ်: ၁ - ၁ (FT)', style: TextStyle(color: Colors.greenAccent)),
                    trailing: Icon(Icons.sports_soccer, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 6. Wallet Screen
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('wallet', AppData.language))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1F1F1F), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('လက်ကျန်ငွေစုစုပေါင်း:', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text('${AppData.balance} Ks', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('ငွေသွင်းငွေထုတ် လုပ်ဆောင်ချက် မှတ်တမ်းများ', style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: AppData.walletHistory.isEmpty
                  ? const Center(child: Text('မှတ်တမ်း မရှိသေးပါ', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: AppData.walletHistory.length,
                      itemBuilder: (context, index) {
                        final item = AppData.walletHistory[index];
                        bool isDeposit = item['type'] == 'ငွေသွင်း';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['type'], style: TextStyle(color: isDeposit ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                              Text('${isDeposit ? "+" : "-"}${item['amount']} Ks', style: TextStyle(color: isDeposit ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// 7. Live Results Screen
class LiveResultsScreen extends StatefulWidget {
  const LiveResultsScreen({super.key});

  @override
  State<LiveResultsScreen> createState() => _LiveResultsScreenState();
}

class _LiveResultsScreenState extends State<LiveResultsScreen> {
  late Future<List<Map<String, dynamic>>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = ApiService.fetchLiveMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('liveResults', AppData.language))),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ပွဲစဉ် အချက်အလက်များ မရှိပါ။', style: TextStyle(color: Colors.grey)));
          }

          final matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final m = matches[index];
              return ListTile(
                title: Text('${m['t1']} vs ${m['t2']}', style: const TextStyle(color: Colors.white)),
                subtitle: Text('${m['league']} (${m['time']})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: Text(m['score'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              );
            },
          );
        },
      ),
    );
  }
}

// 8. Standings Screen
class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('standings', AppData.language))),
      body: ListView.builder(
        itemCount: AppData.standingsList.length,
        itemBuilder: (context, index) {
          final s = AppData.standingsList[index];
          return ListTile(
            leading: Text('${s['pos']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
            title: Text('${s['team']}', style: const TextStyle(color: Colors.white)),
            trailing: Text('P: ${s['p']} | Pts: ${s['pts']}', style: const TextStyle(color: Colors.greenAccent)),
          );
        },
      ),
    );
  }
}

// 9. Points Exchange Screen
class PointsExchangeScreen extends StatefulWidget {
  const PointsExchangeScreen({super.key});

  @override
  State<PointsExchangeScreen> createState() => _PointsExchangeScreenState();
}

class _PointsExchangeScreenState extends State<PointsExchangeScreen> {
  void _exchange() {
    if (AppData.points >= 100) {
      setState(() {
        AppData.points -= 100;
        AppData.balance += 1000.0;
        AppData.saveData();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် ၁၀၀ ကို ငွေကျပ် ၁၀၀၀ သို့ လဲလှယ်ပြီးပါပြီ')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် မလုံလောက်ပါ။')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('pointsExchange', AppData.language))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('လက်ရှိ ပွိုင့်: ${AppData.points} Pts', style: const TextStyle(fontSize: 20, color: Colors.amber)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              onPressed: _exchange,
              child: const Text('ပွိုင့်လဲမည် (100 Pts = 1000 Ks)', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
