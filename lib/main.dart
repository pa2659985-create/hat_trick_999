import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UserData.loadData();
  
  // Notification ခွင့်ပြုချက်တောင်းခြင်း
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

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
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B263B),
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// Global Data & Storage
class UserData {
  static String username = 'zzzzzztoe099';
  static String fullName = 'မင်းမင်းအောင်';
  static double balance = 11500.94;
  static int points = 150;
  static double totalBetAmount = 10900.0;
  static List<Map<String, dynamic>> activeBets = [
    {'betId': '972031975', 'moung': '5', 'bet': 5400.0, 'return': 0.0, 'status': 'ACTIVE', 'time': '26-08-2026 1:00 pm'},
  ];

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_balance', balance);
    await prefs.setInt('user_points', points);
  }

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    balance = prefs.getDouble('user_balance') ?? 11500.94;
    points = prefs.getInt('user_points') ?? 150;
  }
}

// -------------------------------------------------------------
// 1. Login Screen (အကောင့်ဝင်ရန် စာမျက်နှာ)
// -------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController(text: 'zzzzzztoe099');
  final _passController = TextEditingController(text: '123456');

  void _login() {
    if (_userController.text.isNotEmpty && _passController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('အချက်အလက်များ ဖြည့်စွက်ပါ')),
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
                  fillColor: const Color(0xFF1B263B),
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
                  fillColor: const Color(0xFF1B263B),
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

// -------------------------------------------------------------
// 2. Dashboard Screen (ပင်မစာမျက်နှာ - မီနူး (၈) ခုပါဝင်သည်)
// -------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(UserData.fullName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              accountEmail: Text('Username: ${UserData.username}', style: const TextStyle(color: Colors.grey)),
              currentAccountPicture: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
              decoration: const BoxDecoration(color: Color(0xFF1B263B)),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.grey),
              title: const Text('စည်းကမ်းသတ်မှတ်ချက်များ', style: TextStyle(color: Colors.black87)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.grey),
              title: const Text('စကားဝှက် ပြောင်းရန်', style: TextStyle(color: Colors.black87)),
              onTap: () {},
            ),
            const Divider(),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: const [
                  Icon(Icons.campaign, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ငွေနာမည်မှန်ကန်စွာထည့်မှသာ ထုတ်ယူ၍နိုင်ပါမည်။',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueGrey.shade700),
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
                          Text('${UserData.balance.toStringAsFixed(2)} Ks', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('လက်ဆောင် ပွိုင့်များ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('${UserData.points}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('လောင်းထားသောငွေ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('${UserData.totalBetAmount} Ks', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // မီနူးကတ် (၈) ခု
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildMenuCard(context, 'မောင်း', Icons.sports_score, Colors.green, const ParlayScreen()),
                _buildMenuCard(context, 'ဘော်ဒီ/ဂိုးပေါင်း', Icons.sports_soccer, Colors.blue, const FootballOddsScreen()),
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)).then((_) => setState(() {}));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. ငွေစာရင်း Screen (ငွေသွင်း/ငွေထုတ် တကယ့်ပုံစံခွက်များပါဝင်သည်)
// -------------------------------------------------------------
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amountController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  String _selectedMethod = 'KPay';
  String _transactionType = 'ငွေသွင်း';

  void _submitTransaction() {
    if (_amountController.text.isNotEmpty && _accountNoController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_transactionType တောင်းဆိုမှု အောင်မြင်ပါသည်။ Admin အတည်ပြုချက် စောင့်ဆိုင်းနေပါသည်။')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('အချက်အလက်များ အပြည့်အစုံ ဖြည့်စွက်ပါ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ငွေစာရင်း - ငွေသွင်း/ငွေထုတ်')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _transactionType == 'ငွေသွင်း' ? Colors.green : Colors.grey.shade800,
                    ),
                    onPressed: () => setState(() => _transactionType = 'ငွေသွင်း'),
                    child: const Text('ငွေသွင်းမည်', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _transactionType == 'ငွေထုတ်' ? Colors.red : Colors.grey.shade800,
                    ),
                    onPressed: () => setState(() => _transactionType = 'ငွေထုတ်'),
                    child: const Text('ငွေထုတ်မည်', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('ငွေပေးချေသည့် နည်းလမ်း', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              dropdownColor: const Color(0xFF1B263B),
              items: ['KPay', 'WaveMoney', 'KBZ Banking'].map((String method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) => setState(() => _selectedMethod = value!),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1B263B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ငွေပမာဏ (Ks)',
                filled: true,
                fillColor: const Color(0xFF1B263B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountNameController,
              decoration: InputDecoration(
                labelText: 'အကောင့်ပိုင်ရှင် အမည်',
                filled: true,
                fillColor: const Color(0xFF1B263B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountNoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ဖုန်းနံပါတ် (သို့) အကောင့်နံပါတ်',
                filled: true,
                fillColor: const Color(0xFF1B263B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitTransaction,
                child: Text('အတည်ပြုရန် ($_transactionType)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 4. ကျန်ရှိသော မီနူးအသေးစား မျက်နှာပြင်များ
// -------------------------------------------------------------
class ParlayScreen extends StatelessWidget {
  const ParlayScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('မောင်း')), body: const Center(child: Text('ပွဲစဉ်များ မရှိသေးပါ။')));
}

class FootballOddsScreen extends StatelessWidget {
  const FootballOddsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('ဘော်ဒီ/ဂိုးပေါင်း')), body: const Center(child: Text('ပွဲစဉ်များ မရှိသေးပါ။')));
}

class MyBetsScreen extends StatelessWidget {
  const MyBetsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('လောင်းထားသောပွဲစဉ်များ')), body: const Center(child: Text('စာရင်း မရှိပါ။')));
}

class OldMatchesScreen extends StatelessWidget {
  const OldMatchesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('ပွဲစဉ်ဟောင်းများ')), body: const Center(child: Text('မှတ်တမ်း မရှိပါ။')));
}

class LiveResultsScreen extends StatelessWidget {
  const LiveResultsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('ပွဲပြီး ရလဒ်များ')), body: const Center(child: Text('ရလဒ်များ မရှိသေးပါ။')));
}

class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('အဆင့်ဇယား')), body: const Center(child: Text('အချက်အလက် မရှိသေးပါ။')));
}

class PointsExchangeScreen extends StatelessWidget {
  const PointsExchangeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('ပွိုင့်လဲလှယ်')), body: const Center(child: Text('ပွိုင့်လဲလှယ်ရန် မရှိသေးပါ။')));
}
