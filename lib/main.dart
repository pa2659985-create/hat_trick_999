import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.loadData();
  runApp(const HatTrickApp());
}

class HatTrickApp extends StatelessWidget {
  const HatTrickApp({super.key});

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

// App Data Controller (State & Storage)
class AppData {
  static String username = '';
  static double balance = 15000.0;
  static int points = 200;

  static List<Map<String, dynamic>> activeBets = [];
  static List<Map<String, dynamic>> walletHistory = [];
  static List<Map<String, dynamic>> liveResultsToday = [
    {'league': 'ASEAN Championship', 'time': '26-08-2026 7:30 pm', 't1': 'ဗီယက်နാം', 'score': '1 - 2', 't2': 'တိုင်း', 'status': 'FT'},
    {'league': 'Japan Emperor\'s Cup', 'time': '26-08-2026 4:30 pm', 't1': 'ကွန်ဆာဒိုးဆက်ပ်ပိုရို', 'score': 'v', 't2': 'ဗန့်ဖိုရက်ကိဖူ', 'status': ''},
  ];
  static List<Map<String, dynamic>> liveResultsYesterday = [
    {'league': 'Australia Cup', 'time': '25-08-2026 4:00 pm', 't1': 'ကွင်းလန်လိုင်းယွန်း', 'score': '4 - 0', 't2': 'N ဆန်းရှိင်း', 'status': 'FT'},
  ];

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    balance = prefs.getDouble('balance') ?? 15000.0;
    points = prefs.getInt('points') ?? 200;
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
    await prefs.setInt('points', points);
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
      AppData.username = _userController.text;
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
              const Text('HAT TRICK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
              const Text('- 999 -', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 26)),
              const SizedBox(height: 8),
              const Text('နည်းနည်းနဲ့ များကိုက်မည်', style: TextStyle(color: Colors.amber, fontSize: 14)),
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

// 2. Dashboard Screen
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
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('HAT TRICK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(' - 999', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const Text('နည်းနည်းနဲ့ များကိုက်မည်', style: TextStyle(color: Colors.amber, fontSize: 10)),
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
              accountName: Text(AppData.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              accountEmail: const Text('Online Member', style: TextStyle(color: Colors.grey)),
              currentAccountPicture: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
              decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
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
              padding: const EdgeInsets.all(14),
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
                      Text('${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('ပွိုင့်များ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text('${AppData.points} Pts', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                _buildMenuCard(context, 'လောင်းထားသောပွဲစဉ်များ', Icons.receipt_long, Colors.orange, const MyBetsScreen()),
                _buildMenuCard(context, 'ပွဲစဉ်ဟောင်းများ', Icons.calendar_today, Colors.purple, const OldMatchesScreen()),
                _buildMenuCard(context, 'ငွေစာရင်း', Icons.account_balance_wallet, Colors.teal, const WalletScreen()),
                _buildMenuCard(context, 'ပွဲပြီး ရလဒ်များ', Icons.live_tv, Colors.redAccent, const LiveResultsScreen()),
                _buildMenuCard(context, 'အဆင့်ဇယား', Icons.emoji_events, Colors.amber, const StandingsScreen()),
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
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}

// 3. Functional Betting Screen (မောင်း နှင့် ဘော်ဒီ)
class BettingScreen extends StatefulWidget {
  final String title;
  const BettingScreen({super.key, required this.title});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  final TextEditingController _amountController = TextEditingController();
  String selectedMatch = 'ရီးရဲမက်ဒရစ် vs ဆိုစီဒက်';
  double selectedOdds = 1.85;

  void _placeBet() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လောင်းငွေ မှန်ကန်စွာ ထည့်ပါ')));
      return;
    }
    if (AppData.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ကျန်ငွေ မလုံလောက်ပါ')));
      return;
    }

    setState(() {
      AppData.balance -= amount;
      AppData.activeBets.add({
        'betId': '${DateTime.now().millisecondsSinceEpoch}',
        'match': selectedMatch,
        'amount': amount,
        'odds': selectedOdds,
        'status': 'ACTIVE',
        'time': '26-08-2026'
      });
      AppData.walletHistory.add({
        'date': '26-08-2026',
        'type': 'လောင်းကြေး',
        'amount': amount,
        'net': AppData.balance
      });
      AppData.saveData();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွဲစဉ် လောင်းခြင်း အောင်မြင်ပါသည်။')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ရွေးချယ်ထားသောပွဲ: $selectedMatch', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Odds: 1.85', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _placeBet,
                child: const Text('အတည်ပြု လောင်းမည်', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
      appBar: AppBar(title: const Text('လောင်းထားသောပွဲစဉ်များ')),
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
                      Text('အခြေအနေ: ${bet['status']}', style: const TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// 5. Old Matches Screen
class OldMatchesScreen extends StatelessWidget {
  const OldMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွဲစဉ်ဟောင်းများ')),
      body: const Center(child: Text('ရှေးဟောင်း ပွဲစဉ် မှတ်တမ်းများ မရှိသေးပါ။', style: TextStyle(color: Colors.grey))),
    );
  }
}

// 6. Wallet Screen
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ငွေစာရင်း')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
            child: Text('လက်ရှိ လက်ကျန်ငွေ: ${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(fontSize: 16, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          ...AppData.walletHistory.map((item) {
            return ListTile(
              title: Text(item['type'], style: const TextStyle(color: Colors.white)),
              subtitle: Text(item['date'], style: const TextStyle(color: Colors.grey)),
              trailing: Text('- ${item['amount']} Ks', style: const TextStyle(color: Colors.redAccent)),
            );
          }),
        ],
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
  bool isToday = true;

  @override
  Widget build(BuildContext context) {
    final list = isToday ? AppData.liveResultsToday : AppData.liveResultsYesterday;
    return Scaffold(
      appBar: AppBar(title: const Text('ပွဲပြီး ရလဒ်များ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: !isToday ? Colors.green : Colors.grey.shade800),
                    onPressed: () => setState(() => isToday = false),
                    child: const Text('မနေ့က'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isToday ? Colors.green : Colors.grey.shade800),
                    onPressed: () => setState(() => isToday = true),
                    child: const Text('ယနေ့'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final match = list[index];
                return ListTile(
                  title: Text('${match['t1']} vs ${match['t2']}', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(match['league'], style: const TextStyle(color: Colors.grey)),
                  trailing: Text(match['score'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
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
      appBar: AppBar(title: const Text('အဆင့်ဇယား')),
      body: ListView(
        children: const [
          ListTile(leading: Text('1'), title: Text('Real Madrid'), trailing: Text('45 Pts')),
          ListTile(leading: Text('2'), title: Text('Barcelona'), trailing: Text('42 Pts')),
        ],
      ),
    );
  }
}

// 9. Points Exchange Screen (Real Action)
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် ၁၀၀ ကို ငွေကျပ် ၁၀၀၀ သို့ အောင်မြင်စွာ လဲလှယ်ပြီးပါပြီ')));
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                onPressed: _exchange,
                child: const Text('ပွိုင့်လဲမည် (100 Pts = 1000 Ks)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
