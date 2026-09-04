import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserData.loadData();
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

// Global Data & Storage
class UserData {
  static String username = 'zzzzzztoe099';
  static String fullName = 'မင်းမင်းအောင်';
  static double balance = 12000.94;
  static int points = 150;
  
  static List<Map<String, dynamic>> activeBetsList = [
    {'betId': '972031975', 'marns': '5', 'amount': 5400.0, 'return': 0.0, 'status': 'ACTIVE', 'time': '26-08-2026 1:00 pm'},
    {'betId': '972032426', 'marns': '5', 'amount': 2000.0, 'return': 0.0, 'status': 'ACTIVE', 'time': '26-08-2026 1:01 pm'},
    {'betId': '972082914', 'marns': '5', 'amount': 3000.0, 'return': 0.0, 'status': 'ACTIVE', 'time': '26-08-2026 3:04 pm'},
    {'betId': '972083279', 'marns': '11', 'amount': 500.0, 'return': 0.0, 'status': 'ACTIVE', 'time': '26-08-2026 3:05 pm'},
  ];

  static List<Map<String, dynamic>> walletHistory = [
    {'date': '20-08-2026', 'deposit': 0.0, 'withdraw': 0.0, 'bet': 7000.0, 'net': 5000.94, 'time1': '20-08-2026 နေ့လည် ၁၂ နာရီမှ', 'time2': '21-08-2026 နေ့လည် ၁၂ နာရီအထိ'},
    {'date': '21-08-2026', 'deposit': 0.0, 'withdraw': 0.0, 'bet': 5000.0, 'net': 0.94, 'time1': '21-08-2026 နေ့လည် ၁၂ နာရီမှ', 'time2': '22-08-2026 နေ့လည် ၁၂ နာရီအထိ'},
    {'date': '22-08-2026', 'deposit': 50000.0, 'withdraw': 0.0, 'bet': 30000.0, 'net': 20000.94, 'time1': '22-08-2026 နေ့လည် ၁၂ နာရီမှ', 'time2': '23-08-2026 နေ့လည် ၁၂ နာရီအထိ'},
  ];

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    balance = prefs.getDouble('user_balance') ?? 12000.94;
    points = prefs.getInt('user_points') ?? 150;
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_balance', balance);
    await prefs.setInt('user_points', points);
  }
}

// 1. Login Screen
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
              accountName: Text(UserData.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              accountEmail: Text('Username: ${UserData.username}', style: const TextStyle(color: Colors.grey)),
              currentAccountPicture: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
              decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.white70),
              title: const Text('စဉ်းကမ်းသတ်မှတ်ချက်များ', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.white70),
              title: const Text('စကားဝှက် ပြောင်းရန်', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.white70),
              title: const Text('အသင်းအမည်', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white70),
              title: const Text('ဘာသာစကား ရွေးရန်', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('ထွက်ရန်', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Version 12.0.1', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. မီနူး (၈) ခု၏ အသေးစိတ် UI ပုံစံများ (ဓာတ်ပုံအတိုင်း)
// -------------------------------------------------------------

// (၁) မောင်း (Parlay) Screen - ပုံပါ အတိုင်း
class ParlayScreen extends StatelessWidget {
  const ParlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('မောင်းး', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _buildMatchCard('ASEAN Championship', '26-08-2026 7:30 pm', 'ဗိုယက်နാം', '1 +55', 'တိုင်း', '', 'ရိုပေါင်', '3 +95', 'ရိုအောက်', ''),
          _buildMatchCard('Uzbek League', '26-08-2026 8:30 pm', 'မာရှယ်မူဘိုရက်', '', 'N နာမန်ဂန်', '2 +85', 'ရိုပေါင်', '3 +70', 'ရိုအောက်', ''),
          _buildMatchCard('Uzbek League', '26-08-2026 8:30 pm', 'လိုကိုမိုတစ်တတ်ကန့်', '1 +40', 'ကူရက်ချိုဘန်ရှပ်ကောင်', '', 'ရိုပေါင်', '3 +25', 'ရိုအောက်', ''),
          _buildMatchCard('Egyptian Premier League', '26-08-2026 8:30 pm', 'စမ္မဟာ SC', '1 +25', 'A ပီထရိုလီယမ်', '', 'ရိုပေါင်', '2 +10', 'ရိုအောက်', ''),
        ],
      ),
    );
  }

  Widget _buildMatchCard(String league, String time, String t1, String o1, String t2, String o2, String bLabel, String bVal, String uLabel, String uVal) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF2C2C2C),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('★ $league', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('ပွဲချိန် : $time', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Container(padding: const EdgeInsets.all(8), color: const Color(0xFF333333), child: Text(t1, style: const TextStyle(fontSize: 12)))),
                    const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: o1.isNotEmpty ? Colors.green.shade700 : Colors.transparent, child: Text(o1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(padding: const EdgeInsets.all(8), color: const Color(0xFF333333), child: Text(t2, style: const TextStyle(fontSize: 12)))),
                    const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: o2.isNotEmpty ? Colors.green.shade700 : Colors.transparent, child: Text(o2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: Container(padding: const EdgeInsets.all(8), color: const Color(0xFF333333), child: Text(bLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)))),
                    const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: bVal.isNotEmpty ? Colors.green.shade700 : Colors.transparent, child: Text(bVal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(padding: const EdgeInsets.all(8), color: const Color(0xFF333333), child: Text(uLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)))),
                    const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: uVal.isNotEmpty ? Colors.green.shade700 : Colors.transparent, child: Text(uVal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// (၂) ဘော်ဒီ/ဂိုးပေါင်း Screen - ပုံပါ အတိုင်း
class FootballOddsScreen extends StatelessWidget {
  const FootballOddsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ဘော်ဒီ/ဂိုးပေါင်း', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _buildMatchCard('Spanish La Liga', '27-08-2026 1:30 am', 'ရီးရဲမက်ဒရစ်', '2 +40', 'ဆိုစီဒက်', '', 'ရိုပေါင်', '3 -85', 'ရိုအောက်', ''),
          _buildMatchCard('ASEAN Championship', '26-08-2026 7:30 pm', 'ဗိုယက်နാം', '1 +55', 'တိုင်း', '', 'ရိုပေါင်', '3 +95', 'ရိုအောက်', ''),
        ],
      ),
    );
  }

  Widget _buildMatchCard(String league, String time, String t1, String o1, String t2, String o2, String bLabel, String bVal, String uLabel, String uVal) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF2C2C2C),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('★ $league', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('ပွဲချိန် : $time', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Container(padding: const EdgeInsets.all(8), color: const Color(0xFF333333), child: Text(t1, style: const TextStyle(fontSize: 12)))),
                    const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: o1.isNotEmpty ? Colors.green.shade700 : Colors.transparent, child: Text(o1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(padding: const EdgeInsets.all(8), color: const Color(0xFF333333), child: Text(t2, style: const TextStyle(fontSize: 12)))),
                    const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: o2.isNotEmpty ? Colors.green.shade700 : Colors.transparent, child: Text(o2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: Container(padding: const EdgeInsets.all(8), color: const Color(0xFF333333), child: Text(bLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)))),
                    const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: bVal.isNotEmpty ? Colors.green.shade700 : Colors.transparent, child: Text(bVal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(padding: const EdgeInsets.all(8), color: const Color(0xFF333333), child: Text(uLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)))),
                    const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: uVal.isNotEmpty ? Colors.green.shade700 : Colors.transparent, child: Text(uVal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// (၃) လောင်းထားသောပွဲစဉ်များ Screen - ပုံပါ အတိုင်း
class MyBetsScreen extends StatelessWidget {
  const MyBetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('လောင်းထားသောပွဲစဉ်များ', style: TextStyle(color: Colors.white))),
      body: ListView.builder(
        itemCount: UserData.activeBetsList.length,
        itemBuilder: (context, index) {
          final bet = UserData.activeBetsList[index];
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(4)),
                    child: Text(bet['time'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                _rowText('BetId', bet['betId']),
                _rowText('မောင်း', bet['marns']),
                _rowText('လောင်းငွေ', '${bet['amount']}'),
                _rowText('ပြန်ရငွေ', '${bet['return']}'),
                _rowText('နိုင်ငံ/ရုံး', bet['status'], isRed: true),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _rowText(String title, String val, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(val, style: TextStyle(color: isRed ? Colors.red : Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// (၄) ပွဲစဉ်ဟောင်းများ Screen - ကယ်တင်ဒါပါသောပုံစံ
class OldMatchesScreen extends StatefulWidget {
  const OldMatchesScreen({super.key});

  @override
  State<OldMatchesScreen> createState() => _OldMatchesScreenState();
}

class _OldMatchesScreenState extends State<OldMatchesScreen> {
  String selectedDate = '26-08-2026';

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 8, 26),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) {
      setState(() {
        selectedDate = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပွဲစဉ်ဟောင်းများ', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _pickDate,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ရွေးချယ်ထားသောရက်စွဲ: $selectedDate', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            const Text('No History', style: TextStyle(color: Colors.grey, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// (၅) ငွေစာရင်း Screen - ပုံပါအချက်အလက်အတိုင်း
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ငွေစာရင်း', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('20-08-2026 အဖွင့်လက်ကျန်ကျန်', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('12,000.94', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...UserData.walletHistory.map((item) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: Colors.blue.shade700,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['date'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        _wRow('သွင်းငွေ', '${item['deposit']}'),
                        _wRow('ပြန်ရငွေ', '${item['withdraw']}'),
                        _wRow('လောင်းငွေ', '${item['bet']}'),
                        _wRow('ထုတ်ငွေ', '0.0'),
                        _wRow('လက်ကျန်ငွေ', '${item['net']}'),
                        const Divider(color: Colors.grey),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['time1'], style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                              Text(item['time2'], style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _wRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      (val.contains('လက်ကျန်') || title == 'လက်ကျန်ငွေ') 
          ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))])
          : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(val, style: const TextStyle(color: Colors.white, fontSize: 12))])
    );
  }
}

// (၆) ပွဲပြီး ရလဒ်များ Screen - မနေ့က / ယနေ့ ခလုတ်များပါသောပုံစံ
class LiveResultsScreen extends StatefulWidget {
  const LiveResultsScreen({super.key});

  @override
  State<LiveResultsScreen> createState() => _LiveResultsScreenState();
}

class _LiveResultsScreenState extends State<LiveResultsScreen> {
  bool isToday = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွဲပြီး ရလဒ်များ', style: TextStyle(color: Colors.white))),
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
                    child: const Text('မနေ့က', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isToday ? Colors.green : Colors.grey.shade800),
                    onPressed: () => setState(() => isToday = true),
                    child: const Text('ယနေ့', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: isToday ? [
                _resGroup('Australia Cup', [
                  ['26-08-2026 4:00 pm', 'ပရက်တန် လိုင်းယွန်း', '1 - 2', 'S မယ်ဘော်နီ', 'FT']
                ]),
                _resGroup('Japan Emperor\'s Cup', [
                  ['26-08-2026 4:30 pm', 'ကွန်ဆာဒိုးဆက်ပ်ပိုရို', 'v', 'ဗန့်ဖိုရက်ကိဖူ', ''],
                  ['26-08-2026 4:30 pm', 'ဂျူဗီလိုအီဝါတာ', 'v', 'မီယားတက်က', ''],
                ])
              ] : [
                _resGroup('Australia Cup', [
                  ['25-08-2026 4:00 pm', 'ကွင်းလန်လိုင်းယွန်း', '4 - 0', 'N ဆန်းရှိင်း', 'FT']
                ]),
                _resGroup('K League 1', [
                  ['25-08-2026 5:00 pm', 'ဂင်ချွန်းဆန်မူ FC', '0 - 0', 'ဂျိုယွန်ဘက်', 'FT']
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resGroup(String league, List<List<String>> matches) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF2C2C2C),
            child: Text(league, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ...matches.map((m) => Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(m[1], style: const TextStyle(fontSize: 12))),
                Text(m[2], style: TextStyle(color: m[4] == 'FT' ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Expanded(child: Text(m[3], textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
              ],
            ),
          )).toList()
        ],
      ),
    );
  }
}

// (၇) အဆင့်ဇယား Screen
class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('အဆင့်ဇယား', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: const [
          ListTile(leading: Text('1'), title: Text('Real Madrid'), trailing: Text('45 Pts')),
          ListTile(leading: Text('2'), title: Text('Barcelona'), trailing: Text('42 Pts')),
        ],
      ),
    );
  }
}

// (၈) ပွိုင့်လဲလှယ် Screen
class PointsExchangeScreen extends StatefulWidget {
  const PointsExchangeScreen({super.key});

  @override
  State<PointsExchangeScreen> createState() => _PointsExchangeScreenState();
}

class _PointsExchangeScreenState extends State<PointsExchangeScreen> {
  void _exchange() {
    if (UserData.points >= 100) {
      setState(() {
        UserData.points -= 100;
        UserData.balance += 1000.0;
      });
      UserData.saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ပွိုင့် ၁၀၀ ကို ငွေကျပ် ၁၀၀၀ သို့ အောင်မြင်စွာ လဲလှယ်ပြီးပါပြီ')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ပွိုင့် မလုံလောက်ပါ။')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွိုင့်လဲလှယ်', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('လက်ရှိ ပွိုင့်: ${UserData.points}', style: const TextStyle(fontSize: 20, color: Colors.amber)),
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
