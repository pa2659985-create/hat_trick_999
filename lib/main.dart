import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
      title: '555 SPORT',
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

class AppStrings {
  static Map<String, Map<String, String>> localizedValues = {
    'မြန်မာ': {
      'appName': '555 SPORT',
      'tagline': 'နည်းနည်းလောင်း များများနိုင်',
      'login': 'အကောင့်ဝင်မည်',
      'username': 'အသုံးပြုသူ အမည်',
      'password': 'စကားဝှက်',
      'balance': 'လက်ကျန်ငွေ',
      'points': 'လက်ဆောင် ပွိုင့်များ',
      'wallet': 'ငွေစာရင်း',
      'myBets': 'လောင်းထားသောပွဲစဉ်များ',
      'oldMatches': 'ပွဲစဉ်ဟောင်းများ',
      'liveResults': 'ပွဲပြီး ရလဒ်များ',
      'standings': 'အဆင့်ဇယား',
      'pointsExchange': 'ပွိုင့်လဲလှယ်',
      'logout': 'ထွက်ရန်',
    },
    'English': {
      'appName': '555 SPORT',
      'tagline': 'Play Smart, Win Big',
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      'balance': 'Balance',
      'points': 'Reward Points',
      'wallet': 'Wallet',
      'myBets': 'My Bets',
      'oldMatches': 'Old Matches',
      'liveResults': 'Live Results',
      'standings': 'Standings',
      'pointsExchange': 'Points Exchange',
      'logout': 'Logout',
    },
  };

  static String get(String key, String lang) {
    return localizedValues[lang]?[key] ?? localizedValues['မြန်မာ']![key] ?? key;
  }
}

class ApiService {
  static const String apiKey = '5a87133d1c764efb8525d81e82d605fd'; 
  static const String baseUrl = 'https://api.football-data.org/v4/matches';

  static Future<List<Map<String, dynamic>>> fetchLiveMatches() async {
    List<Map<String, dynamic>> allMatches = [
      {
        'league': 'Indonesia Super League',
        'time': '05-09-2026 3:00 pm',
        't1': 'B ဆိုလို FC',
        'score': '0 - 0',
        't2': 'P ဆူရာဘယ',
        'status': 'SCHEDULED',
        'hOdds': '= -.25',
        'aOdds': '',
        'overOdds': '3 +80',
        'underOdds': 'ဂိုးအောက်',
      },
      {
        'league': 'Indonesia Super League',
        'time': '05-09-2026 3:00 pm',
        't1': 'ပါဆော ကေ',
        'score': '0 - 0',
        't2': 'ဒီဝါ် Utd FC',
        'status': 'SCHEDULED',
        'hOdds': '',
        'aOdds': '= -75',
        'overOdds': '3 +35',
        'underOdds': 'ဂိုးအောက်',
      },
      {
        'league': 'Indonesia Super League',
        'time': '05-09-2026 3:00 pm',
        't1': 'PSIM ယောရှက် ကာတာ',
        'score': '0 - 0',
        't2': 'P တန်ဂျာရမ်',
        'status': 'SCHEDULED',
        'hOdds': '1 +85',
        'aOdds': '',
        'overOdds': '2 -50',
        'underOdds': 'ဂိုးအောက်',
      },
      {
        'league': 'J3 League',
        'time': '05-09-2026 3:30 pm',
        't1': 'FC ဂီဖူ',
        'score': '0 - 0',
        't2': 'ဖိုရ်ရန်ကန်န်နာတာဝ',
        'status': 'SCHEDULED',
        'hOdds': '1 +85',
        'aOdds': '',
        'overOdds': '3 +80',
        'underOdds': 'ဂိုးအောက်',
      },
    ];

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
            'league': m['competition']['name'] ?? 'World League',
            'time': '05-09-2026 4:00 pm',
            't1': m['homeTeam']['name'] ?? 'Home',
            'score': '${m['score']['fullTime']['home'] ?? 0} - ${m['score']['fullTime']['away'] ?? 0}',
            't2': m['awayTeam']['name'] ?? 'Away',
            'status': m['status'] ?? 'SCHEDULED',
            'hOdds': '= -.50',
            'aOdds': '',
            'overOdds': '2.5 +90',
            'underOdds': 'ဂိုးအောက်',
          });
        }
      }
    } catch (e) {
      print('API Error: $e');
    }

    return allMatches;
  }
}

class AppData {
  static String displayName = 'User';
  static String username = '';
  static String language = 'မြန်မာ';
  
  static double balance = 50000.0;
  static int points = 250;
  static double totalActiveBetsAmount = 0.0;

  static List<Map<String, dynamic>> activeBets = [];
  static List<Map<String, dynamic>> oldMatchesList = [
    {'time': '04-09-2026 3:00 pm', 'match': 'မန်စီးတီး vs လီဗာပူးလ်', 'result': '2 - 1'},
    {'time': '04-09-2026 6:00 pm', 'match': 'ရီးရဲမက်ဒရစ် vs ဘာစီလိုနာ', 'result': '3 - 2'},
  ];
  static List<Map<String, dynamic>> liveResultsList = [
    {'time': '05-09-2026 1:00 pm', 'match': 'ချယ်ဆီး vs အာဆင်နယ်', 'result': '1 - 1 (ပြီးဆုံး)'},
  ];

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
    language = prefs.getString('language') ?? 'မြန်မာ';
    balance = prefs.getDouble('balance') ?? 50000.0;
    points = prefs.getInt('points') ?? 250;
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', displayName);
    await prefs.setString('username', username);
    await prefs.setString('language', language);
    await prefs.setDouble('balance', balance);
    await prefs.setInt('points', points);
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

  void _login() {
    setState(() {
      AppData.username = _userController.text.isEmpty ? 'User999' : _userController.text;
      AppData.displayName = AppData.username;
      AppData.saveData();
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
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
              Text(AppStrings.get('appName', AppData.language), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 36)),
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(AppStrings.get('appName', AppData.language), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 20)),
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
              leading: const Icon(Icons.receipt_long, color: Colors.orange),
              title: Text(AppStrings.get('myBets', AppData.language), style: const TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBetsScreen())); },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: Text(AppStrings.get('oldMatches', AppData.language), style: const TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const OldMatchesScreen())); },
            ),
            ListTile(
              leading: const Icon(Icons.live_tv, color: Colors.redAccent),
              title: Text(AppStrings.get('liveResults', AppData.language), style: const TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveResultsScreen())); },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard, color: Colors.amber),
              title: Text(AppStrings.get('pointsExchange', AppData.language), style: const TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const PointsExchangeScreen())).then((_) => _refresh()); },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.teal),
              title: Text(AppStrings.get('wallet', AppData.language), style: const TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen())); },
            ),
            const Divider(color: Colors.grey),
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
              child: Row(
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
                _buildMenuCard(context, 'ဘော်ဒီ / ဂိုးပေါင်း', Icons.sports_soccer, Colors.green, const BettingScreen(title: 'ဘော်ဒီ / ဂိုးပေါင်း')),
                _buildMenuCard(context, AppStrings.get('myBets', AppData.language), Icons.receipt_long, Colors.orange, const MyBetsScreen()),
                _buildMenuCard(context, AppStrings.get('oldMatches', AppData.language), Icons.history, Colors.blue, const OldMatchesScreen()),
                _buildMenuCard(context, AppStrings.get('liveResults', AppData.language), Icons.live_tv, Colors.redAccent, const LiveResultsScreen()),
                _buildMenuCard(context, AppStrings.get('pointsExchange', AppData.language), Icons.card_giftcard, Colors.amber, const PointsExchangeScreen()),
                _buildMenuCard(context, AppStrings.get('standings', AppData.language), Icons.emoji_events, Colors.teal, const StandingsScreen()),
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

class BettingScreen extends StatefulWidget {
  final String title;
  const BettingScreen({super.key, required this.title});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  late Future<List<Map<String, dynamic>>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = ApiService.fetchLiveMatches();
  }

  void _showBetBottomSheet(Map<String, dynamic> match, String teamName, String oddsValue, String betType) {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1F1F1F),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ပွဲစဉ် - ${match['t1']} vs ${match['t2']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Text('ရွေးချယ်မှု: $teamName ($betType: $oddsValue)', style: const TextStyle(color: Colors.greenAccent, fontSize: 13)),
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'လောင်းမည့် ငွေပမာဏ (Ks)',
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    double amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လောင်းငွေ မှန်ကန်စွာ ထည့်ပါ။')));
                      return;
                    }
                    if (AppData.balance < amount) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ကျန်ငွေ မလုံလောက်ပါ။')));
                      return;
                    }

                    setState(() {
                      AppData.balance -= amount;
                      AppData.totalActiveBetsAmount += amount;
                      AppData.activeBets.add({
                        'betId': '${DateTime.now().millisecondsSinceEpoch}',
                        'match': '${match['t1']} vs ${match['t2']}',
                        'choice': '$teamName [$betType: $oddsValue]',
                        'amount': amount,
                        'time': match['time'],
                      });
                      AppData.saveData();
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွဲစဉ် လောင်းခြင်း အောင်မြင်ပါသည်။')));
                  },
                  child: const Text('အတည်ပြု လောင်းမည်', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ပွဲစဉ်များ မရှိသေးပါ။', style: TextStyle(color: Colors.grey)));
          }

          final matches = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final m = matches[index];
              bool hasHODds = m['hOdds'] != null && m['hOdds'].toString().isNotEmpty;
              bool hasAOdds = m['aOdds'] != null && m['aOdds'].toString().isNotEmpty;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF222222),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.green, size: 14),
                          const SizedBox(width: 6),
                          Text(m['league'], style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('ပွဲချိန် : ${m['time']}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: InkWell(
                                  onTap: () => _showBetBottomSheet(m, m['t1'], hasHODds ? m['hOdds'] : '0', 'ဘော်ဒီ'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4)),
                                    child: Text(m['t1'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (hasHODds)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                  child: Text(m['hOdds'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              if (hasAOdds)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                  child: Text(m['aOdds'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 4,
                                child: InkWell(
                                  onTap: () => _showBetBottomSheet(m, m['t2'], hasAOdds ? m['aOdds'] : '0', 'ဘော်ဒီ'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4)),
                                    child: Text(m['t2'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
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
                                  onTap: () => _showBetBottomSheet(m, 'ဂိုးပေါ်', m['overOdds'].split(' ').last, 'ဂိုးပေါ်/အောက်'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('ဂိုးပေါ်', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                child: Text(m['overOdds'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showBetBottomSheet(m, 'ဂိုးအောက်', 'အောက်', 'ဂိုးပေါ်/အောက်'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('ဂိုးအောက်', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

class MyBetsScreen extends StatelessWidget {
  const MyBetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('myBets', AppData.language))),
      body: AppData.activeBets.isEmpty
          ? const Center(child: Text('လောင်းထားသော ပွဲစဉ် မရှိသေးပါ။', style: TextStyle(color: Colors.grey)))
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
                      Text('ပွဲချိန်: ${bet['time']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('ပွဲစဉ်: ${bet['match']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('ရွေးချယ်မှု: ${bet['choice']}', style: const TextStyle(color: Colors.greenAccent)),
                      const SizedBox(height: 4),
                      Text('လောင်းငွေ: ${bet['amount']} Ks', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    ],
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
      appBar: AppBar(title: Text(AppStrings.get('oldMatches', AppData.language))),
      body: ListView.builder(
        itemCount: AppData.oldMatchesList.length,
        itemBuilder: (context, index) {
          final item = AppData.oldMatchesList[index];
          return ListTile(
            title: Text(item['match'], style: const TextStyle(color: Colors.white)),
            subtitle: Text('ပွဲချိန်: ${item['time']}', style: const TextStyle(color: Colors.grey)),
            trailing: Text(item['result'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
}

class LiveResultsScreen extends StatelessWidget {
  const LiveResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('liveResults', AppData.language))),
      body: ListView.builder(
        itemCount: AppData.liveResultsList.length,
        itemBuilder: (context, index) {
          final item = AppData.liveResultsList[index];
          return ListTile(
            title: Text(item['match'], style: const TextStyle(color: Colors.white)),
            subtitle: Text('ပွဲချိန်: ${item['time']}', style: const TextStyle(color: Colors.grey)),
            trailing: Text(item['result'], style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          );
        },
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
  void _exchangePoints() {
    if (AppData.points >= 100) {
      setState(() {
        AppData.points -= 100;
        AppData.balance += 5000.0;
        AppData.saveData();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် ၁၀၀ ကို 5000 Ks သို့ အောင်မြင်စွာ လဲလှယ်ပြီးပါပြီ။')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် မလုံလောက်ပါ။ (အနည်းဆုံး ၁၀၀ လိုအပ်သည်)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('pointsExchange', AppData.language))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1F1F1F), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('လက်ရှိ ပွိုင့်လက်ကျန်:', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text('${AppData.points} Pts', style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 45)),
              onPressed: _exchangePoints,
              child: const Text('ပွိုင့် ၁၀၀ လျှင် ၅၀၀၀ ကျပ်သို့ လဲမည်', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

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
          ],
        ),
      ),
    );
  }
}

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
