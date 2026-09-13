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

class HatTrickApp extends StatefulWidget {
  const HatTrickApp({super.key});

  @override
  State<HatTrickApp> createState() => _HatTrickAppState();
}

class _HatTrickAppState extends State<HatTrickApp> {
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
      title: '999SPORT',
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

  static Future<List<Map<String, dynamic>>> fetchMatches() async {
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
          allMatches.add({
            'id': '${m['id']}',
            'league': m['competition']['name'] ?? 'League',
            'time': m['utcDate'] != null ? m['utcDate'].toString().replaceFirst('T', ' ').substring(0, 16) : '05-09-2026 8:00 pm',
            't1': m['homeTeam']['name'] ?? 'Home Team',
            't2': m['awayTeam']['name'] ?? 'Away Team',
            'status': m['status'] ?? 'UPCOMING',
            'odds': {
              'homeWin': 1.85,
              'awayWin': 1.95,
              'centerVal': '2.5',
              'over2.5': 1.90,
              'under2.5': 1.85,
            }
          });
        }
      }
    } catch (e) {
      print('API Error: $e');
    }

    if (allMatches.isEmpty) {
      allMatches.add({
        'id': 'm1',
        'league': 'ASEAN Championship',
        'time': '26-08-2026 7:30 pm',
        't1': 'ဗီယက်နမ်',
        't2': 'ထိုင်း',
        'status': 'UPCOMING',
        'odds': {
          'homeWin': 1.55,
          'awayWin': 1.80,
          'centerVal': '2.5',
          'over2.5': 1.95,
          'under2.5': 1.75,
        }
      });
      allMatches.add({
        'id': 'm2',
        'league': 'Uzbek League',
        'time': '26-08-2026 8:30 pm',
        't1': 'နာဆာဗူတိုရ်က်',
        't2': 'ဂျူနမ်ရန်ကုန်',
        'status': 'UPCOMING',
        'odds': {
          'homeWin': 1.65,
          'awayWin': 1.85,
          'centerVal': '2.5',
          'over2.5': 1.70,
          'under2.5': 1.90,
        }
      });
    }

    return allMatches;
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
            'league': m['competition']['name'] ?? 'League',
            'match': '${m['homeTeam']['name']} vs ${m['awayTeam']['name']}',
            'score': '${score['home'] ?? 0} - ${score['away'] ?? 0}',
            'date': m['utcDate'] != null ? m['utcDate'].substring(0, 10) : '2026-09-05',
            'result': 'ပြီးဆုံး (FT)',
          });
        }
      }
    } catch (e) {
      print('Old Matches API Error: $e');
    }

    if (oldMatches.isEmpty) {
      oldMatches.add({
        'league': 'ASEAN Championship',
        'match': 'ဗီယက်နမ် vs ထိုင်း',
        'score': '2 - 1',
        'date': '2026-08-26',
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
  static String displayName = 'User';
  static String username = '';
  static String password = '123';
  static double balance = 0.0; // အကောင့်အသစ်အတွက် ငွေ 0
  static int points = 0;       // အကောင့်အသစ်အတွက် ပွိုင့် 0

  static List<Map<String, dynamic>> activeBets = [];
  static List<Map<String, dynamic>> parlaySlip = []; 

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    displayName = prefs.getString('displayName') ?? 'User';
    username = prefs.getString('username') ?? '';
    password = prefs.getString('password') ?? '123';
    balance = prefs.getDouble('balance') ?? 0.0;
    points = prefs.getInt('points') ?? 0;

    try {
      if (username.isNotEmpty) {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(username).get();
        if (userDoc.exists) {
          var data = userDoc.data()!;
          balance = (data['balance'] ?? balance).toDouble();
          points = data['points'] ?? points;
        }
      }
    } catch (e) {
      print('Cloud Database Sync Error: $e');
    }
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', displayName);
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setDouble('balance', balance);
    await prefs.setInt('points', points);

    try {
      if (username.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(username).set({
          'displayName': displayName,
          'balance': balance,
          'points': points,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Cloud Database Save Error: $e');
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
    if (_userController.text.isNotEmpty && _passController.text.isNotEmpty) {
      setState(() {
        AppData.username = _userController.text;
        AppData.displayName = _userController.text;
      });
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
                  labelText: 'အသုံးပြုသူ အမည်',
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
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.greenAccent),
              title: const Text('ပရိုไฟล์ စီမံရန်', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
                    .then((_) => _refresh());
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('ထွက်ရန်', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
                          const Text('လက်ကျန်ငွေ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Text('လက်ဆောင် ပွိုင့်များ', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                      const Text('လောင်းထားသောငွေ', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                _buildMenuCard(context, 'မောင်း', Icons.sports_score, Colors.green, const BettingScreen(isParlay: true)),
                _buildMenuCard(context, 'ဘော်ဒီ/ဂိုးပေါင်း', Icons.sports_soccer, Colors.blue, const BettingScreen(isParlay: false)),
                _buildMenuCard(context, 'လောင်းထားသောပွဲစဉ်များ', Icons.receipt_long, Colors.orange, const MyBetsScreen()),
                _buildMenuCard(context, 'ပွဲစဉ်ဟောင်းများ', Icons.calendar_today, Colors.purple, const OldMatchesScreen()),
                _buildMenuCard(context, 'ငွေစာရင်း', Icons.account_balance_wallet, Colors.teal, const WalletScreen()),
                _buildMenuCard(context, 'ပွဲပြီး ရလဒ်များ', Icons.live_tv, Colors.amber, const FinishedResultsScreen()),
                _buildMenuCard(context, 'အဆင့်ဇယား', Icons.emoji_events, Colors.indigo, const StandingsScreen()),
                _buildMenuCard(context, 'ပွိုင့်လဲလှယ်', Icons.monetization_on, Colors.lightGreen, const PointsExchangeScreen()),
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
  final _passController = TextEditingController(text: AppData.password);

  void _updateProfile() async {
    setState(() {
      AppData.displayName = _nameController.text;
      AppData.password = _passController.text;
    });
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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'အမည်ပြောင်းရန်', filled: true, fillColor: Color(0xFF1F1F1F)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'စကားဝှက်အသစ်', filled: true, fillColor: Color(0xFF1F1F1F)),
            ),
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

class BettingScreen extends StatefulWidget {
  final bool isParlay; // true = မောင်း, false = ဘော်ဒီ/ဂိုးပေါင်း (Single)
  const BettingScreen({super.key, required this.isParlay});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  late Future<List<Map<String, dynamic>>> _matchesFuture;
  
  // Single Bet အတွက် ရွေးချယ်မှုသိမ်းရန်
  Map<String, dynamic>? _selectedSingleBet;
  final TextEditingController _singleAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _matchesFuture = ApiService.fetchMatches();
  }

  void _handleSelection(Map<String, dynamic> match, String betType, String selection, double odds) {
    if (widget.isParlay) {
      // မောင်း (Parlay) အတွက် အကွက်ရွေးချယ်ခြင်း
      setState(() {
        int existingIndex = AppData.parlaySlip.indexWhere(
          (item) => item['matchId'] == match['id'] && item['betType'] == betType && item['selection'] == selection
        );

        if (existingIndex >= 0) {
          AppData.parlaySlip.removeAt(existingIndex);
        } else {
          AppData.parlaySlip.removeWhere((item) => item['matchId'] == match['id'] && item['betType'] == betType);
          AppData.parlaySlip.add({
            'matchId': match['id'],
            'matchName': '${match['t1']} vs ${match['t2']}',
            'betType': betType,
            'selection': selection,
            'odds': odds,
          });
        }
      });
    } else {
      // ဘော်ဒီ/ဂိုးပေါင်း (Single Bet - တစ်ပွဲတည်းသာ)
      setState(() {
        _selectedSingleBet = {
          'matchId': match['id'],
          'matchName': '${match['t1']} vs ${match['t2']}',
          'betType': betType,
          'selection': selection,
          'odds': odds,
        };
      });
      _showSingleBetBottomSheet();
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
                  const Text('ဘော်ဒီ/ဂိုးပေါင်း (တစ်ပွဲလောင်းရန်)', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('ပွဲစဉ်: ${_selectedSingleBet!['matchName']}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  Text('ရွေးချယ်မှု: ${_selectedSingleBet!['betType']} (${_selectedSingleBet!['selection']}) | Odds: ${_selectedSingleBet!['odds']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _singleAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setModalState(() {}),
                    decoration: InputDecoration(
                      labelText: 'လောင်းမည့် ငွေပမာဏ (Ks)',
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
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
                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ငွေပမာဏ မှန်ကန်စွာ ထည့်ပါ။')));
                          return;
                        }
                        if (AppData.balance < amount) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ကျန်ငွေ မလုံလောက်ပါ။')));
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
        title: Text(widget.isParlay ? 'မောင်း (Parlay)' : 'ဘော်ဒီ / ဂိုးပေါင်း (Single)'),
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
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ပွဲစဉ်များ ရယူ၍မရပါ။', style: TextStyle(color: Colors.grey)));
          }

          final matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final m = matches[index];
              final odds = m['odds'];

              bool isHomeSelected = _isSelected(m['id'], 'အနိုင်/အရှုံး', m['t1']);
              bool isAwaySelected = _isSelected(m['id'], 'အနိုင်/အရှုံး', m['t2']);
              bool isOverSelected = _isSelected(m['id'], 'ဂိုးပေါင်း', 'ဂိုးပေါ်');
              bool isUnderSelected = _isSelected(m['id'], 'ဂိုးပေါင်း', 'ဂိုးအောက်');

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // လိဂ်နာမည်နှင့် အချိန်
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m['league'], style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('ပွဲချိန် : ${m['time']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // အထက်တန်း အသင်း ၂ သင်း (Home & Away with Odds) - ၄ ကွက်စပ် ပုံစံ
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'အနိုင်/အရှုံး', m['t1'], odds['homeWin']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isHomeSelected ? Colors.amber : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      m['t1'],
                                      style: TextStyle(
                                        color: isHomeSelected ? Colors.black : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '+${odds['homeWin'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isHomeSelected ? Colors.black : Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'အနိုင်/အရှုံး', m['t2'], odds['awayWin']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isAwaySelected ? Colors.amber : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      m['t2'],
                                      style: TextStyle(
                                        color: isAwaySelected ? Colors.black : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  Text(
                                    '+${odds['awayWin'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isAwaySelected ? Colors.black : Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // အောက်ဘက် ဂိုးပေါ် / ဂိုးအောက် နှင့် အလယ်တွင် သီးသန့်ကိန်းဂဏန်းအကွက်
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'ဂိုးပေါင်း', 'ဂိုးပေါ်', odds['over2.5']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isOverSelected ? Colors.amber : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ဂိုးပေါ်',
                                    style: TextStyle(
                                      color: isOverSelected ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '+${odds['over2.5'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isOverSelected ? Colors.black : Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // အလယ်ဗဟို ကိန်းဂဏန်းထည့်ရန် သီးသန့်အကွက်ငယ်
                        Container(
                          width: 45,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            odds['centerVal'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleSelection(m, 'ဂိုးပေါင်း', 'ဂိုးအောက်', odds['under2.5']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isUnderSelected ? Colors.amber : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ဂိုးအောက်',
                                    style: TextStyle(
                                      color: isUnderSelected ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '+${odds['under2.5'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isUnderSelected ? Colors.black : Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
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

  // မြန်မာနိုင်ငံသုံး မောင်းဘောနပ်စ် စည်းမျဉ်း (အနည်းဆုံး ၂ ပွဲ၊ အများဆုံး ၁၅ ပွဲ)
  double _calculateBonusPercent() {
    int count = AppData.parlaySlip.length;
    if (count >= 14) return 0.50; // ၁၄ မှ ၁၅ ပွဲ - 50%
    if (count >= 12) return 0.40; // ၁၂ မှ ၁၃ ပွဲ - 40%
    if (count >= 10) return 0.30; // ၁၀ မှ ၁၁ ပွဲ - 30%
    if (count >= 8) return 0.25;  // ၈ မှ ၉ ပွဲ - 25%
    if (count >= 6) return 0.20;  // ၆ မှ ၇ ပွဲ - 20%
    if (count >= 4) return 0.15;  // ၄ မှ ၅ ပွဲ - 15%
    if (count == 3) return 0.10;  // ၃ ပွဲ - 10%
    return 0.0;                   // ၂ ပွဲ - 0%
  }

  void _confirmParlayBet() async {
    int count = AppData.parlaySlip.length;
    if (count < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မောင်းလောင်းရန် အနည်းဆုံး ၂ ပွဲ ပါရှိရပါမည်။')));
      return;
    }
    if (count > 15) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('အများဆုံး ၁၅ ပွဲထိသာ တစ်ကြိမ်တည်း လောင်းခွင့်ရှိပါသည်။')));
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လောင်းငွေ ပမာဏ မှန်ကန်စွာ ထည့်ပါ။')));
      return;
    }
    if (AppData.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ကျန်ငွေ မလုံလောက်ပါ။')));
      return;
    }

    double totalOdds = _calculateTotalOdds();
    double bonusPct = _calculateBonusPercent();
    double baseWin = amount * totalOdds;
    double potentialWin = baseWin + (baseWin * bonusPct);

    setState(() {
      AppData.balance -= amount;
      AppData.activeBets.add({
        'betId': '${DateTime.now().millisecondsSinceEpoch}',
        'type': 'မောင်း (${AppData.parlaySlip.length} ပွဲတွဲ)',
        'matches': List.from(AppData.parlaySlip),
        'amount': amount,
        'totalOdds': totalOdds,
        'bonusPct': bonusPct * 100,
        'potentialWin': potentialWin,
        'status': 'ACTIVE',
      });
      AppData.parlaySlip.clear();
    });
    await AppData.saveData();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မောင်းလောင်းခြင်း အောင်မြင်ပါသည်။')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double totalOdds = _calculateTotalOdds();
    double bonusPct = _calculateBonusPercent();
    double betAmount = double.tryParse(_amountController.text) ?? 0.0;
    double baseWin = betAmount * totalOdds;
    double estimatedWin = baseWin + (baseWin * bonusPct);

    return Scaffold(
      appBar: AppBar(title: const Text('မောင်းစလစ်နှင့် အပိုဆုကြေး')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: AppData.parlaySlip.isEmpty
                  ? const Center(child: Text('မောင်းစလစ်ထဲတွင် ပွဲစဉ်များ မရှိသေးပါ။ (အနည်းဆုံး ၂ ပွဲ လိုအပ်သည်)', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: AppData.parlaySlip.length,
                      itemBuilder: (context, index) {
                        final item = AppData.parlaySlip[index];
                        return Card(
                          color: const Color(0xFF1F1F1F),
                          child: ListTile(
                            title: Text(item['matchName'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                            subtitle: Text('${item['betType']} (${item['selection']}) | Odds: ${item['odds']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  AppData.parlaySlip.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (AppData.parlaySlip.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1F1F1F), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('စုစုပေါင်း Odds:', style: TextStyle(color: Colors.grey)),
                        Text(totalOdds.toStringAsFixed(2), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('မောင်း အပိုဆုကြေး (Bonus):', style: TextStyle(color: Colors.grey)),
                        Text('${(bonusPct * 100).toStringAsFixed(0)} %', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'လောင်းမည့် ငွေပမာဏ (Ks)',
                        filled: true,
                        fillColor: const Color(0xFF2C2C2C),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ဘောနပ်စ်အပါ အနိုင်ရမည့်ငွေ:', style: TextStyle(color: Colors.grey)),
                        Text('${estimatedWin.toStringAsFixed(0)} Ks', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _confirmParlayBet,
                  child: const Text('မောင်းလောင်းမည် အတည်ပြုရန် (၂ မှ ၁၅ မောင်း)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MyBetsScreen extends StatefulWidget {
  const MyBetsScreen({super.key});

  @override
  State<MyBetsScreen> createState() => _MyBetsScreenState();
}

class _MyBetsScreenState extends State<MyBetsScreen> {
  void _settleBet(int index, bool isWin) async {
    var bet = AppData.activeBets[index];
    if (bet['status'] != 'ACTIVE') return;

    setState(() {
      if (isWin) {
        AppData.balance += (bet['potentialWin'] as double);
        bet['status'] = 'WON (အနိုင်ရ)';
      } else {
        bet['status'] = 'LOST (အရှုံး)';
      }
    });
    await AppData.saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ပွဲစဉ်ရလဒ် အတည်ပြုပြီးပါပြီ: ${bet['status']}')),
    );
  }

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
                bool isActive = bet['status'] == 'ACTIVE';

                return Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
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
                      const SizedBox(height: 4),
                      Text('လောင်းငွေ: ${bet['amount']} Ks', style: const TextStyle(color: Colors.greenAccent)),
                      Text('ရနိုင်မည့်ငွေ: ${bet['potentialWin']} Ks', style: const TextStyle(color: Colors.white)),
                      if (isActive) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(80, 30)),
                              onPressed: () => _settleBet(index, false),
                              child: const Text('အရှုံး', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(80, 30)),
                              onPressed: () => _settleBet(index, true),
                              child: const Text('အနိုင်', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        )
                      ]
                    ],
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
  late Future<List<Map<String, dynamic>>> _oldMatchesFuture;
  String? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _oldMatchesFuture = ApiService.fetchOldMatches();
  }

  void _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter = picked.toString().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပွဲစဉ်ဟောင်းများ'),
        actions: [
          // ပွဲစဉ်ဟောင်းများ အပေါ်ဘက်ညာဘက်ထောင့်တွင် Calendar ခလုတ်
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.greenAccent),
            onPressed: () => _pickDate(context),
            tooltip: 'ရက်စွဲရွေးရန်',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedDateFilter != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade900,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ရွေးချယ်ထားသော ရက်စွဲ: $_selectedDateFilter', style: const TextStyle(color: Colors.amber)),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => setState(() => _selectedDateFilter = null),
                    child: const Text('ဖျက်ရန်', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _oldMatchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('ပွဲစဉ်ဟောင်း အချက်အလက် မရှိပါ။'));
                }

                List<Map<String, dynamic>> oldMatches = snapshot.data!;
                if (_selectedDateFilter != null) {
                  oldMatches = oldMatches.where((m) => m['date'] == _selectedDateFilter).toList();
                }

                if (oldMatches.isEmpty) {
                  return const Center(child: Text('ဤရက်စွဲအတွက် ပွဲစဉ်ဟောင်း မရှိပါ။', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  itemCount: oldMatches.length,
                  itemBuilder: (context, index) {
                    var om = oldMatches[index];
                    return Card(
                      color: const Color(0xFF1F1F1F),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(om['match'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${om['league']} | ရက်စွဲ: ${om['date']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: Text(om['score'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
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

class FinishedResultsScreen extends StatefulWidget {
  const FinishedResultsScreen({super.key});

  @override
  State<FinishedResultsScreen> createState() => _FinishedResultsScreenState();
}

class _FinishedResultsScreenState extends State<FinishedResultsScreen> {
  late Future<List<Map<String, dynamic>>> _finishedFuture;

  @override
  void initState() {
    super.initState();
    _finishedFuture = ApiService.fetchOldMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွဲပြီး ရလဒ်များ')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _finishedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ပွဲပြီးရလဒ်များ မရှိပါ။'));
          }
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              var item = list[index];
              return Card(
                color: const Color(0xFF1F1F1F),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(item['match'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(item['league'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  trailing: Text(item['score'], style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late Future<List<Map<String, dynamic>>> _standingsFuture;

  @override
  void initState() {
    super.initState();
    _standingsFuture = ApiService.fetchStandings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('အဆင့်ဇယား')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _standingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('အဆင့်ဇယား မရှိပါ။'));
          }
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              var s = list[index];
              return ListTile(
                leading: Text('${s['pos']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                title: Text(s['team'], style: const TextStyle(color: Colors.white)),
                subtitle: Text('ပွဲစဉ်: ${s['played']}', style: const TextStyle(color: Colors.grey)),
                trailing: Text('${s['points']} Pts', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1F1F1F), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('လက်ကျန်ငွေစုစုပေါင်း:', style: TextStyle(color: Colors.grey, fontSize: 15)),
              Text('${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
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
