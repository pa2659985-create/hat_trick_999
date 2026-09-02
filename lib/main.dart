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
  
  static List<Map<String, dynamic>> activeBetsList = [
    {'match': 'Man Utd vs Arsenal', 'type': 'ဘော်ဒီ', 'amount': 5400.0, 'status': 'လောင်းထားဆဲ'},
    {'match': 'Real Madrid vs Barcelona', 'type': 'မောင်း (၃ပွဲ)', 'amount': 5500.0, 'status': 'လောင်းထားဆဲ'},
  ];

  static List<Map<String, dynamic>> oldMatchesList = [
    {'match': 'Liverpool vs Chelsea', 'result': '2 - 1', 'date': '25-08-2026'},
    {'match': 'AC Milan vs Inter', 'result': '0 - 0', 'date': '24-08-2026'},
  ];

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    balance = prefs.getDouble('user_balance') ?? 11500.94;
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

// 2. Dashboard Screen (မီနူး (၈) ခုပါဝင်သည်)
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            // မီနူး (၈) ခု
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
// 3. မီနူး (၈) ခု၏ သီးသန့် အတွင်းပိုင်း စာမျက်နှာများ
// -------------------------------------------------------------

// (၁) မောင်း Screen
class ParlayScreen extends StatelessWidget {
  const ParlayScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('မောင်း (Parlay)')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          ListTile(title: Text('Man City vs Liverpool'), subtitle: Text('Odds: 1.85'), trailing: Icon(Icons.add_circle, color: Colors.green)),
          ListTile(title: Text('Real Madrid vs Atletico'), subtitle: Text('Odds: 2.10'), trailing: Icon(Icons.add_circle, color: Colors.green)),
          ListTile(title: Text('Bayern vs Dortmund'), subtitle: Text('Odds: 1.75'), trailing: Icon(Icons.add_circle, color: Colors.green)),
        ],
      ),
    );
  }
}

// (၂) ဘော်ဒီ/ဂိုးပေါင်း Screen
class FootballOddsScreen extends StatelessWidget {
  const FootballOddsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ဘော်ဒီ / ဂိုးပေါင်း')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Card(child: ListTile(title: Text('Arsenal vs Chelsea'), subtitle: Text('Body: Arsenal (-0.5) | Over/Under: 2.5'))),
          Card(child: ListTile(title: Text('PSG vs Marseille'), subtitle: Text('Body: PSG (-1.0) | Over/Under: 3.0'))),
        ],
      ),
    );
  }
}

// (၃) လောင်းထားသောပွဲစဉ်များ Screen
class MyBetsScreen extends StatelessWidget {
  const MyBetsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('လောင်းထားသောပွဲစဉ်များ')),
      body: ListView.builder(
        itemCount: UserData.activeBetsList.length,
        itemBuilder: (context, index) {
          final bet = UserData.activeBetsList[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(bet['match'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('အမျိုးအစား: ${bet['type']} | ပမာဏ: ${bet['amount']} Ks'),
              trailing: Text(bet['status'], style: const TextStyle(color: Colors.amber)),
            ),
          );
        },
      ),
    );
  }
}

// (၄) ပွဲစဉ်ဟောင်းများ Screen
class OldMatchesScreen extends StatelessWidget {
  const OldMatchesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွဲစဉ်ဟောင်းများ ရလဒ်')),
      body: ListView.builder(
        itemCount: UserData.oldMatchesList.length,
        itemBuilder: (context, index) {
          final match = UserData.oldMatchesList[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(match['match']),
              subtitle: Text('ရက်စွဲ: ${match['date']}'),
              trailing: Text(match['result'], style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

// (၅) ငွေစာရင်း (Wallet) Screen
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amountController = TextEditingController();
  final _accountNoController = TextEditingController();
  String _selectedMethod = 'KPay';
  String _transactionType = 'ငွေသွင်း';

  void _submit() {
    if (_amountController.text.isNotEmpty && _accountNoController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_transactionType တောင်းဆိုမှု အောင်မြင်ပါသည်။')),
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
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _transactionType == 'ငွေသွင်း' ? Colors.green : Colors.grey),
                    onPressed: () => setState(() => _transactionType = 'ငွေသွင်း'),
                    child: const Text('ငွေသွင်း'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _transactionType == 'ငွေထုတ်' ? Colors.red : Colors.grey),
                    onPressed: () => setState(() => _transactionType = 'ငွေထုတ်'),
                    child: const Text('ငွေထုတ်'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              dropdownColor: const Color(0xFF1B263B),
              items: ['KPay', 'WaveMoney', 'KBZ Banking'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => _selectedMethod = v!),
              decoration: const InputDecoration(border: OutlineInputBorder(), filled: true),
            ),
            const SizedBox(height: 16),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ငွေပမာဏ (Ks)', border: OutlineInputBorder(), filled: true)),
            const SizedBox(height: 16),
            TextField(controller: _accountNoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ဖုန်းနံပါတ် (သို့) အကောင့်နံပါတ်', border: OutlineInputBorder(), filled: true)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _submit,
                child: Text('အတည်ပြုရန် ($_transactionType)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// (၆) ပွဲပြီး ရလဒ်များ Screen
class LiveResultsScreen extends StatelessWidget {
  const LiveResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွဲပြီး ရလဒ်များ (Live Results)')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Card(child: ListTile(title: Text('Real Madrid 3 - 1 Barcelona'), subtitle: Text('FT - ပြီးဆုံး'))),
          Card(child: ListTile(title: Text('Man Utd 2 - 2 Liverpool'), subtitle: Text('FT - ပြီးဆုံး'))),
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
      appBar: AppBar(title: const Text('လိဂ် အဆင့်ဇယား')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          ListTile(leading: Text('1'), title: Text('Real Madrid'), trailing: Text('45 Pts')),
          ListTile(leading: Text('2'), title: Text('Barcelona'), trailing: Text('42 Pts')),
          ListTile(leading: Text('3'), title: Text('Atletico'), trailing: Text('38 Pts')),
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
        const SnackBar(content: Text('ပွိုင့် မလုံလောက်ပါ။ (အနည်းဆုံး ၁၀၀ လိုအပ်သည်)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ပွိုင့်လဲလှယ်ခြင်း')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('လက်ရှိ ပွိုင့်: ${UserData.points}', style: const TextStyle(fontSize: 20, color: Colors.amber)),
            const SizedBox(height: 10),
            const Text('ပွိုင့် ၁၀၀ လျှင် ငွေကျပ် ၁၀၀၀ ရရှိမည်', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
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

