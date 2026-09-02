import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const HatTrickApp());
}

class HatTrickApp extends StatelessWidget {
  const HatTrickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HAT TRICK 999',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
      ),
      home: const LoginScreen(),
    );
  }
}

// ==================== 1. LOGIN SCREEN ====================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'HAT TRICK 999',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'ဖုန်းနံပါတ်',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'စကားဝှက်',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Login နှိပ်ပါက Home Dashboard သోသို့ သွားမည်
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      'အကောင့်ဝင်မည်',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 2. HOME DASHBOARD ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        title: const Text('HAT TRICK 999', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                'လက်ကျန်: 0 Ks',
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildMenuCard(context, 'မောင်း', Icons.sports_soccer, const SecureApiMixParlayScreen()),
            _buildMenuCard(context, 'ဘောလုံး/ဂိုးပေါင်း', Icons.sports, null),
            _buildMenuCard(context, 'လောင်းထားသောပွဲများ', Icons.list_alt, null),
            _buildMenuCard(context, 'ငွေစာရင်း', Icons.account_balance_wallet, null),
            _buildMenuCard(context, 'မှတ်တမ်း', Icons.history, null),
            _buildMenuCard(context, 'ပရိုဖိုင်', Icons.person, null),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget? targetScreen) {
    return InkWell(
      onPressed: () {
        if (targetScreen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title မျက်နှာပြင် ဆောက်လုပ်ဆဲ ဖြစ်ပါသည်။')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.greenAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 3. MIX PARLAY SCREEN (API INTEGRATED) ====================
class SecureApiMixParlayScreen extends StatefulWidget {
  const SecureApiMixParlayScreen({super.key});

  @override
  State<SecureApiMixParlayScreen> createState() => _SecureApiMixParlayScreenState();
}

class _SecureApiMixParlayScreenState extends State<SecureApiMixParlayScreen> {
  List matches = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMatchesWithApiKey();
  }

  Future<void> fetchMatchesWithApiKey() async {
    const String apiKey = '5a87133d1c764efb8525d81e82d605fd'; 
    const String apiUrl = 'https://api.football-data.org/v4/matches';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          matches = data['matches'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'ဒေတာရယူရာတွင် အမှားအယွင်းရှိပါသည် (Error Code: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'အင်တာနက်ချိတ်ဆက်မှု မရှိပါ သို့မဟုတ် ဆာဗာချို့ယွင်းနေပါသည်။';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        title: const Text('မောင်း (Live API)', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 14), textAlign: TextAlign.center),
                  ),
                )
              : matches.isEmpty
                  ? const Center(
                      child: Text('ယနေ့အတွက် ပွဲစဉ်များ မရှိသေးပါ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        final homeTeam = match['homeTeam']['name'] ?? 'Team A';
                        final awayTeam = match['awayTeam']['name'] ?? 'Team B';
                        final utcDate = match['utcDate'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ပွဲချိန် : $utcDate', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: Text(homeTeam, style: const TextStyle(color: Colors.white, fontSize: 13))),
                                  const Text(' vs ', style: TextStyle(color: Colors.greenAccent)),
                                  Expanded(child: Text(awayTeam, style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.right)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
