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
  static String displayName = 'မင်းမင်းအောင်';
  static String username = 'zzzzztoe099';
  static String password = '123';
  static String language = 'မြန်မာ';
  static String selectedTeam = 'မြန်မာ';
  
  static double balance = 0.0;
  static int points = 0;
  static double totalActiveBetsAmount = 0.0; // လောင်းထားသော စုစုပေါင်းငွေ

  static List<Map<String, dynamic>> activeBets = [];
  static List<Map<String, dynamic>> walletHistory = [];
  static List<Map<String, dynamic>> liveResultsToday = [
    {'league': 'ASEAN Championship', 'time': '26-08-2026 7:30 pm', 't1': 'ဗီယက်နမ်', 'score': '1 - 2', 't2': 'တိုင်း', 'status': 'FT'},
    {'league': 'Japan Emperor\'s Cup', 'time': '26-08-2026 4:30 pm', 't1': 'ကွန်ဆာဒိုးဆက်ပ်ပိုရို', 'score': 'v', 't2': 'ဗန့်ဖိုရက်ကိဖူ', 'status': ''},
  ];
  static List<Map<String, dynamic>> liveResultsYesterday = [
    {'league': 'Australia Cup', 'time': '25-08-2026 4:00 pm', 't1': 'ကွင်းလန်လိုင်းယွန်း', 'score': '4 - 0', 't2': 'N ဆန်းရှိင်း', 'status': 'FT'},
  ];

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    displayName = prefs.getString('displayName') ?? 'မင်းမင်းအောင်';
    username = prefs.getString('username') ?? 'zzzzztoe099';
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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: AppData.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('အမည် ပြင်ဆင်ရန်', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'အမည်အသစ်', labelStyle: TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('မလုပ်တော့ပါ', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              setState(() {
                AppData.displayName = nameController.text;
                AppData.saveData();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('အမည် ပြောင်းလဲခြင်း အောင်မြင်ပါသည်။')));
            },
            child: const Text('သိမ်းမည်', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('စကားဝှက် ပြောင်းရန်', style: TextStyle(color: Colors.white)),
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
        title: const Text('စည်းကမ်းသတ်မှတ်ချက်များ', style: TextStyle(color: Colors.white)),
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
        title: const Text('အသင်းအမည် ရွေးချယ်ရန်', style: TextStyle(color: Colors.white)),
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
        title: const Text('ဘာသာစကား ရွေးချယ်ရန်', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['မြန်မာ', 'English'].map((lang) {
            return ListTile(
              title: Text(lang, style: const TextStyle(color: Colors.white)),
              trailing: AppData.language == lang ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() {
                  AppData.language = lang;
                  AppData.saveData();
                });
                Navigator.pop(context);
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
              accountName: Row(
                children: [
                  Expanded(child: Text(AppData.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.greenAccent, size: 18),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditProfileDialog();
                    },
                  ),
                ],
              ),
              accountEmail: Text('Username: ${AppData.username}', style: const TextStyle(color: Colors.grey)),
              currentAccountPicture: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
              decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.grey),
              title: const Text('စည်းကမ်းသတ်မှတ်ချက်များ', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showTermsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.grey),
              title: const Text('စကားဝှက် ပြောင်းရန်', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.amber),
              title: const Text('အသင်းအမည်', style: TextStyle(color: Colors.white)),
              subtitle: Text(AppData.selectedTeam, style: const TextStyle(color: Colors.greenAccent)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showTeamDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: const Text('ဘာသာစကားရွေးရန်', style: TextStyle(color: Colors.white)),
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
              child: Text('Version 12.0.1', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
            // ပုံထဲကအတိုင်း လက်ကျန်ငွေ၊ ပွိုင့်နှင့် လောင်းထားသောငွေ ပါဝင်သည့် အကွက်
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
                          const Text('လက်ကျန်ငွေ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const Divider(color: Colors.grey, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('လောင်းထားသောငွေ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('${AppData.totalActiveBetsAmount.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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

// 3. Betting Screen
class BettingScreen extends StatefulWidget {
  final String title;
  const BettingScreen({super.key, required this.title});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  final TextEditingController _amountController = TextEditingController();
  final String selectedMatch = 'ရီးရဲမက်ဒရစ် vs ဆိုစီဒက်';
  final double selectedOdds = 1.85;

  void _placeBet() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လောင်းငွေ မှန်ကန်စွာ ထည့်ပါ')));
      return;
    }
    if (AppData.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ကျန်ငွေ မလုံလောက်ပါ (ကျေးဇူးပြု၍ ငွေအရင်သွင်းပါ)')));
      return;
    }

    setState(() {
      AppData.balance -= amount;
      AppData.totalActiveBetsAmount += amount; // လောင်းထားသောငွေ ပမာဏကို ပေါင်းထည့်သည်
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
class OldMatchesScreen extends StatefulWidget {
  const OldMatchesScreen({super.key});

  @override
  State<OldMatchesScreen> createState() => _OldMatchesScreenState();
}

class _OldMatchesScreenState extends State<OldMatchesScreen> {
  String selectedDateStr = 'ရက်စွဲ ရွေးချယ်ရန်';
  List<Map<String, dynamic>> filteredMatches = [];

  final List<Map<String, dynamic>> allOldMatches = [
    {'date': '25-08-2026', 'league': 'Australia Cup', 't1': 'ကွင်းလန်လိုင်းယွန်း', 'score': '4 - 0', 't2': 'N ဆန်းရှိင်း'},
    {'date': '24-08-2026', 'league': 'Premier League', 't1': 'မန်ချက်စတာယူနိုက်တက်', 'score': '2 - 1', 't2': 'လီဗာပူး'},
    {'date': '24-08-2026', 'league': 'La Liga', 't1': 'ရီးရဲမက်ဒရစ်', 'score': '3 - 0', 't2': 'ဘာစီလိုနာ'},
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2028),
    );
    if (picked != null) {
      setState(() {
        selectedDateStr = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        filteredMatches = allOldMatches.where((match) => match['date'] == selectedDateStr).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပွဲစဉ်ဟောင်းများ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.greenAccent),
            onPressed: () => _selectDate(context),
            tooltip: 'ရက်စွဲ ရွေးရန်',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ရွေးချယ်ထားသော ရက်စွဲ: ', style: TextStyle(color: Colors.grey)),
                Text(selectedDateStr, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: filteredMatches.isEmpty
                ? const Center(
                    child: Text('ဤရက်စွဲအတွက် ရှေးဟောင်း ပွဲစဉ် မှတ်တမ်းများ မရှိပါ။', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: filteredMatches.length,
                    itemBuilder: (context, index) {
                      final match = filteredMatches[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: ListTile(
                          title: Text('${match['t1']} vs ${match['t2']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(match['league'], style: const TextStyle(color: Colors.grey)),
                          trailing: Text(match['score'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// 6. Wallet Screen
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  void _showDepositDialog() {
    final depositController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('ငွေသွင်းရန် (Deposit)', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: depositController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'သွင်းမည့် ပမာဏ (Ks)',
            labelStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('မလုပ်တော့ပါ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              double depositAmount = double.tryParse(depositController.text) ?? 0.0;
              if (depositAmount > 0) {
                setState(() {
                  AppData.balance += depositAmount;
                  AppData.walletHistory.insert(0, {
                    'date': '26-08-2026',
                    'type': 'ငွေသွင်းခြင်း',
                    'amount': depositAmount,
                    'net': AppData.balance
                  });
                  AppData.saveData();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ငွေကျပ် ${depositAmount.toStringAsFixed(0)} အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ကျေးဇူးပြု၍ မှန်ကန်သော ငွေပမာဏ ထည့်ပါ')),
                );
              }
            },
            child: const Text('အတည်ပြုမည်', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ငွေစာရင်း'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
            onPressed: _showDepositDialog,
            tooltip: 'ငွေသွင်းရန်',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('လက်ရှိ လက်ကျန်ငွေ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${AppData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(fontSize: 20, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _showDepositDialog,
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('ငွေသွင်း', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('ငွေကြေး လှုပ်ရှားမှု မှတ်တမ်း', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AppData.walletHistory.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('မှတ်တမ်း မရှိသေးပါ။', style: TextStyle(color: Colors.grey))),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AppData.walletHistory.length,
                  itemBuilder: (context, index) {
                    final item = AppData.walletHistory[index];
                    bool isDeposit = item['type'] == 'ငွေသွင်းခြင်း';
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListTile(
                        title: Text(item['type'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: Text(
                          '${isDeposit ? '+' : '-'} ${item['amount']} Ks',
                          style: TextStyle(color: isDeposit ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် ၁၀၀ ကို ငွေကျပ် ၁၀၀၀ သို့ အောင်မြင်စွာ လဲလှယ်ပြီးပါပြီ')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ပွိုင့် မလုံလောက်ပါ။')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_const
    return const Scaffold(
      appBar: AppBar(title: Text('ပွိုင့်လဲလှယ်')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        // ignore: unnecessary_const
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('လက်ရှိ ပွိုင့်: ${AppData.points} Pts', style: TextStyle(fontSize: 20, color: Colors.amber)),
            SizedBox(height: 20),
            // SizedBox(
            //   width: double.infinity,
            //   height: 50,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            //     onPressed: _exchange,
            //     child: const Text('ပွိုင့်လဲမည် (100 Pts = 1000 Ks)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
