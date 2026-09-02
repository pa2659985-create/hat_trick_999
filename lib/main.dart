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
  
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    balance = prefs.getDouble('user_balance') ?? 11500.94;
    points = prefs.getInt('user_points') ?? 150;
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildMenuCard(context, 'မောင်း', Icons.sports_score, Colors.green, const PlaceholderScreen(title: 'မောင်း')),
                _buildMenuCard(context, 'ဘော်ဒီ/ဂိုးပေါင်း', Icons.sports_soccer, Colors.blue, const PlaceholderScreen(title: 'ဘော်ဒီ/ဂိုးပေါင်း')),
                _buildMenuCard(context, 'လောင်းထားသောပွဲစဉ်များ', Icons.receipt_long, Colors.orange, const PlaceholderScreen(title: 'လောင်းထားသောပွဲစဉ်များ')),
                _buildMenuCard(context, 'ပွဲစဉ်ဟောင်းများ', Icons.calendar_today, Colors.purple, const PlaceholderScreen(title: 'ပွဲစဉ်ဟောင်းများ')),
                _buildMenuCard(context, 'ငွေစာရင်း', Icons.account_balance_wallet, Colors.teal, const WalletScreen()),
                _buildMenuCard(context, 'ပွဲပြီး ရလဒ်များ', Icons.live_tv, Colors.redAccent, const PlaceholderScreen(title: 'ပွဲပြီး ရလဒ်များ')),
                _buildMenuCard(context, 'အဆင့်ဇယား', Icons.emoji_events, Colors.amber, const PlaceholderScreen(title: 'အဆင့်ဇယား')),
                _buildMenuCard(context, 'ပွိုင့်လဲလှယ်', Icons.monetization_on, Colors.indigo, const PlaceholderScreen(title: 'ပွိုင့်လဲလှယ်')),
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
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

// 3. Wallet Screen (ငွေသွင်း/ငွေထုတ်)
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

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title စာမျက်နှာ', style: const TextStyle(fontSize: 18))),
    );
  }
}
