import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Cloud Database အတွက် ထည့်သွင်းခြင်း

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
    // ၃။ Push Notifications (Foreground Listener) အပြည့်အစုံ ထည့်သွင်းခြင်း
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Foreground Notification received: ${message.notification!.title}');
      }
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

class ApiService {
  static const String apiKey = '5a87133d1c764efb8525d81e82d605fd'; 
  static const String baseUrl = 'https://api.football-data.org/v4/matches';

  static Future<List<Map<String, dynamic>>> fetchMatches() async {
    List<Map<String, dynamic>> allMatches = [
      {
        'id': 'm1',
        'league': 'Indonesia Super League',
        'time': '05-09-2026 3:00 pm',
        't1': 'B ဆိုလို FC',
        't2': 'P ဆူရာဘယသ',
        'teamOdds': '= -.25',
        'oddsVal': 1.85,
        'status': 'LIVE',
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
          if (m['status'] == 'TIMED' || m['status'] == 'SCHEDULED') {
            allMatches.add({
              'id': '${m['id']}',
              'league': m['competition']['name'] ?? 'World League',
              'time': '05-09-2026 8:00 pm',
              't1': m['homeTeam']['name'] ?? 'Home Team',
              't2': m['awayTeam']['name'] ?? 'Away Team',
              'teamOdds': '1 +55',
              'oddsVal': 1.80,
              'status': 'UPCOMING',
            });
          }
        }
      }
    } catch (e) {
      print('API Error: $e');
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
            'date': m['utcDate'].substring(0, 10),
            'result': 'ပြီးဆုံး (FT)',
          });
        }
      }
    } catch (e) {
      print('Old Matches API Error: $e');
    }

    return oldMatches;
  }
}

class AppData {
  static String displayName = 'User';
  static String username = '';
  static String password = '123';
  static double balance = 50000.0;
  static int points = 250;

  static List<Map<String, dynamic>> activeBets = [];
  static List<Map<String, dynamic>> parlaySlip = []; 

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    displayName = prefs.getString('displayName') ?? 'User';
    username = prefs.getString('username') ?? '';
    password = prefs.getString('password') ?? '123';
    balance = prefs.getDouble('balance') ?? 50000.0;
    points = prefs.getInt('points') ?? 250;

    // ၁။ Cloud Database (Firestore) မှ အချက်အလက်များ တွဲဖက်ဆွဲထုတ်ရန် စနစ်အဆင်သင့်လုပ်ခြင်း
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

    // ၁။ Cloud Database သို့ အချက်အလက်များ အမြဲတမ်းသိမ်းဆည်းခြင်း (Cloud Backup)
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
              const Text('HAT TRICK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
              const Text('- 999 -', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 26)),
              const SizedBox(height: 8),
              const Text('နည်းနည်းလောင်း များများနိုင်', style: TextStyle(color: Colors.amber, fontSize: 14)),
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
            Text('HAT TRICK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(' - 999', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
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
                      const Text('လက်ကျန်ငွေ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text('${AppData.balance.toStringAsFixed(0)} Ks', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('လက်ဆောင် ပွိုင့်များ', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                _buildMenuCard(context, 'မောင်းလောင်းရန်', Icons.sports_score, Colors.green, const BettingScreen()),
                _buildMenuCard(context, 'မောင်းစလစ် (${AppData.parlaySlip.length})', Icons.list_alt, Colors.amber, const ParlaySlipScreen()),
                _buildMenuCard(context, 'လောင်းထားသောပွဲများ', Icons.receipt_long, Colors.orange, const MyBetsScreen()),
                _buildMenuCard(context, 'ပွဲစဉ်ဟောင်းများ', Icons.calendar_today, Colors.purple, const OldMatchesScreen()),
                _buildMenuCard(context, 'ငွေစာရင်း', Icons.account_balance_wallet, Colors.teal, const WalletScreen()),
                _buildMenuCard(context, 'ပွိုင့်လဲလှယ်', Icons.monetization_on, Colors.indigo, const PointsExchangeScreen()),
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
  const BettingScreen({super.key});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  late Future<List<Map<String, dynamic>>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = ApiService.fetchMatches();
  }

  void _addToParlay(Map<String, dynamic> match, String betType, String selection, double odds) {
    setState(() {
      AppData.parlaySlip.removeWhere((item) => item['matchId'] == match['id']);
      AppData.parlaySlip.add({
        'matchId': match['id'],
        'matchName': '${match['t1']} vs ${match['t2']}',
        'betType': betType,
        'selection': selection,
        'odds': odds,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('မောင်းစလစ်သို့ ထည့်ပြီးပါပြီ (${AppData.parlaySlip.length} ပွဲ)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('မောင်းလောင်းရန် (Parlay Selection)'),
        actions: [
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
      // ၂။ API Error Handling UI ပြသခြင်း
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  const Text('အင်တာနက်ချိတ်ဆက်မှု သို့မဟုတ် API ချို့ယွင်းနေပါသည်။', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() { _matchesFuture = ApiService.fetchMatches(); }),
                    child: const Text('ထပ်မံကြိုးစားရန်'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ပွဲစဉ်များ မရှိသေးပါ။'));
          }

          final matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final m = matches[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ပွဲချိန် : ${m['time']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _addToParlay(m, 'အိမ်ကွင်း', m['t1'], m['oddsVal']),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(4)),
                              child: Text(m['t1'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _addToParlay(m, 'ဘော်ဒီကြေး', m['teamOdds'], m['oddsVal']),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                            child: Text(m['teamOdds'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: InkWell(
                            onTap: () => _addToParlay(m, 'အဝေးကွင်း', m['t2'], m['oddsVal']),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(4)),
                              child: Text(m['t2'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
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

  double _calculateBonusPercent() {
    int count = AppData.parlaySlip.length;
    if (count >= 4) return 0.20;
    if (count == 3) return 0.10;
    return 0.0;
  }

  void _confirmParlayBet() async {
    if (AppData.parlaySlip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('မောင်းစလစ်ထဲတွင် ပွဲစဉ်မရှိသေးပါ။')));
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
      appBar: AppBar(title: const Text('မောင်းစလစ်နှင့် ဘောနပ်စ် (Parlay Slip)')),
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
                            title: Text(item['matchName'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            subtitle: Text('ရွေးချယ်မှု: ${item['betType']} (${item['selection']}) | Odds: ${item['odds']}', style: const TextStyle(color: Colors.greenAccent)),
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
                  child: const Text('မောင်းလောင်းမည် အတည်ပြုရန်', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
        AppData.balance += bet['potentialWin'];
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
      appBar: AppBar(title: const Text('လောင်းထားသော ပွဲစဉ်များ (Auto Settlement)')),
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
                              child: const Text('အရှုံး (Loss)', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(80, 30)),
                              onPressed: () => _settleBet(index, true),
                              child: const Text('အနိုင် (Win)', style: TextStyle(fontSize: 12)),
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

  @override
  void initState() {
    super.initState();
    _oldMatchesFuture = ApiService.fetchOldMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွဲစဉ်ဟောင်း ရလဒ်များ (API)')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _oldMatchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('ပွဲစဉ်ဟောင်း အချက်အလက် ဆွဲထုတ်ရာတွင် အမှားအယွင်းရှိသည်။', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ပွဲစဉ်ဟောင်း အချက်အလက် မရှိပါ။'));
          }

          final oldMatches = snapshot.data!;
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
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(om['score'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(om['result'], style: const TextStyle(color: Colors.amber, fontSize: 10)),
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
              const Text('လက်ကျန်ငွေစုစုပေါင်း:', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text('${AppData.balance.toStringAsFixed(0)} Ks', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
