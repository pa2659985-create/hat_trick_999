import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserData.loadData(); // အက်ပ်စစချင်း သိမ်းဆည်းထားသော ဒေတာများကို ဖတ်မည်
  runApp(const HatTrickApp());
}

class HatTrickApp extends StatelessWidget {
  const HatTrickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HAT TRICK 999',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// -------------------------------------------------------------
// Local Storage (SharedPreferences) ဖြင့် ဒေတာသိမ်းဆည်းမည့် Class
// -------------------------------------------------------------
class UserData {
  static double balance = 11500.94;
  static List<Map<String, dynamic>> activeBets = [];

  // ဒေတာများကို ဖုန်းအတွင်း SharedPreferences ဖြင့် သိမ်းဆည်းရန်
  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_balance', balance);
    // List<Map> ကို String (JSON) ပြောင်း၍ သိမ်းမည်
    String encodedBets = jsonEncode(activeBets);
    await prefs.setString('active_bets', encodedBets);
  }

  // သိမ်းဆည်းထားသော ဒေတာများကို ပြန်လည်ဖတ်ယူရန်
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    balance = prefs.getDouble('user_balance') ?? 11500.94;
    String? encodedBets = prefs.getString('active_bets');
    if (encodedBets != null) {
      List decodedList = jsonDecode(encodedBets);
      activeBets = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  }
}

// -------------------------------------------------------------
// 1. Dashboard Screen (ပင်မစာမျက်နှာ - Wallet နှင့် မျက်နှာပြင်များ)
// -------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeTab(),
      const MyBetsTab(),
      const WalletTab(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'ပွဲစဉ်များ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'လောင်းထားသည့်စာရင်း'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'ငွေစာရင်း (Wallet)'),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Home Tab (ပွဲစဉ်များနှင့် ဘော်ဒီ/ဂိုးပေါင်း Screen သို့သွားရန်)
// -------------------------------------------------------------
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.sports_kabaddi, color: Colors.greenAccent, size: 22),
            SizedBox(width: 8),
            Text('HAT TRICK ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('999', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Card Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('လက်ကျန်ငွေ (Balance)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 5),
                      Text('${UserData.balance.toStringAsFixed(2)} ကျပ်', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletTab()));
                    },
                    child: const Text('ငွေသွင်း/ထုတ်', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('အားကစားအမျိုးအစားများ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 12),
            // Football Odds Entry Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FootballOddsScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.sports_soccer, color: Colors.greenAccent, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ဘော်ဒီ / ဂိုးပေါင်း', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('စပိန်လာလီဂါ၊ ယူဇဘက်နှင့် အခြားလိဂ်ပွဲစဉ်များ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. Football Odds Screen (ဘော်ဒီ/ဂိုးပေါင်း စာမျက်နှာ)
// -------------------------------------------------------------
class FootballOddsScreen extends StatefulWidget {
  const FootballOddsScreen({super.key});

  @override
  State<FootballOddsScreen> createState() => _FootballOddsScreenState();
}

class _FootballOddsScreenState extends State<FootballOddsScreen> {
  final List<Map<String, dynamic>> matchData = [
    {
      'league': 'Spanish La Liga',
      'matches': [
        {
          'time': '27-08-2026 1:30 am',
          'homeTeam': 'ရီးရဲမက်ဒရစ်',
          'awayTeam': 'ဆိုစီဒက်',
          'bodyOdds': '2 +40',
          'isHomeFav': true,
          'overUnderOdds': '3 -85',
        }
      ]
    },
    {
      'league': 'ASEAN Championship',
      'matches': [
        {
          'time': '26-08-2026 7:30 pm',
          'homeTeam': 'ဗီယက်နမ်',
          'awayTeam': 'ထိုင်း',
          'bodyOdds': '1 +55',
          'isHomeFav': true,
          'overUnderOdds': '3 +95',
        }
      ]
    },
    {
      'league': 'Uzbek League',
      'matches': [
        {
          'time': '26-08-2026 8:30 pm',
          'homeTeam': 'မရှာယ်မုဘိုရက်',
          'awayTeam': 'N နာမန်ဂန်',
          'bodyOdds': '2 +85',
          'isHomeFav': false,
          'overUnderOdds': '3 +70',
        },
        {
          'time': '26-08-2026 8:30 pm',
          'homeTeam': 'လိုကိုမိုးတစ်တက်ကန့်',
          'awayTeam': 'ကူရုက်ချီဘုရှ်ရုက်ကော',
          'bodyOdds': '1 +40',
          'isHomeFav': true,
          'overUnderOdds': '3 +25',
        }
      ]
    },
    {
      'league': 'Egyptian Premier League',
      'matches': [
        {
          'time': '26-08-2026 8:30 pm',
          'homeTeam': 'စမူဟာ SC',
          'awayTeam': 'A ပီထရိုလီယမ်',
          'bodyOdds': '1 +25',
          'isHomeFav': true,
          'overUnderOdds': '2 +10',
        }
      ]
    },
  ];

  // လောင်းမည့် ပမာဏထည့်သွင်းရန် Dialog ပေါ်စေရန်
  void openBetSlipDialog(String matchInfo, String betType, String oddsValue) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('လောင်းကြေးအတည်ပြုရန်', style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ပွဲစဉ်: $matchInfo', style: const TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 5),
              Text('ရွေးချယ်မှု: $betType ($oddsValue)', style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ထိုးမည့်ငွေပမာဏ (ကျပ်)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.green)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('မလုပ်တော့ပါ', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                double? amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ကျေးဇူးပြု၍ ငွေပမာဏမှန်ကန်စွာ ထည့်ပါ')));
                  return;
                }
                if (amount > UserData.balance) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ကျန်ငွေ မလုံလောက်ပါ')));
                  return;
                }

                setState(() {
                  UserData.balance -= amount;
                  UserData.activeBets.add({
                    'match': matchInfo,
                    'type': betType,
                    'odds': oddsValue,
                    'amount': amount,
                    'time': DateTime.now().toString().substring(0, 16),
                  });
                });
                await UserData.saveData();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('လောင်းကစားမှု အောင်မြင်ပါသည်'), backgroundColor: Colors.green),
                );
              },
              child: const Text('အတည်ပြုမည်', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('HAT TRICK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('999', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(width: 10),
            Text('ဘော်ဒီ/ဂိုးပေါင်း', style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: matchData.length,
        itemBuilder: (context, leagueIndex) {
          final league = matchData[leagueIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xFF2C2C2C),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      league['league'],
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ...List.generate(league['matches'].length, (matchIndex) {
                final match = league['matches'][matchIndex];
                String matchTitle = '${match['homeTeam']} vs ${match['awayTeam']}';
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        color: const Color(0xFF1E1E1E),
                        child: Text(
                          'ပွဲချိန် : ${match['time']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      // ဘော်ဒီကြေး အကွက်
                      Container(
                        color: const Color(0xFFE0E0E0),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => openBetSlipDialog(matchTitle, 'ဘော်ဒီ (${match['homeTeam']})', match['isHomeFav'] ? match['bodyOdds'] : '0'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(match['homeTeam'], style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    ),
                                    if (match['isHomeFav'])
                                      Text(match['bodyOdds'], style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => openBetSlipDialog(matchTitle, 'ဘော်ဒီ (${match['awayTeam']})', !match['isHomeFav'] ? match['bodyOdds'] : '0'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(match['awayTeam'], style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    ),
                                    if (!match['isHomeFav'])
                                      Text(match['bodyOdds'], style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      // ဂိုးပေါင်းကြေး အကွက်
                      Container(
                        color: const Color(0xFFE0E0E0),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => openBetSlipDialog(matchTitle, 'ဂိုးပေါ်', match['overUnderOdds']),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('ဂိုးပေါ်', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 16),
                                    Text(match['overUnderOdds'], style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => openBetSlipDialog(matchTitle, 'ဂိုးအောက်', '0'),
                                child: const Center(
                                  child: Text('ဂိုးအောက်', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. My Bets Tab (လောင်းထားသည့် မှတ်တမ်းများ Screen)
// -------------------------------------------------------------
class MyBetsTab extends StatelessWidget {
  const MyBetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('လောင်းထားသည့် စာရင်းများ', style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: UserData.activeBets.isEmpty
          ? const Center(
              child: Text('လတ်တလော လောင်းထားသော စာရင်း မရှိသေးပါ။', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              itemCount: UserData.activeBets.length,
              itemBuilder: (context, index) {
                final bet = UserData.activeBets[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(bet['match'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(bet['time'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ရွေးချယ်မှု: ${bet['type']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 13)),
                          Text('ထိုးငွေ: ${bet['amount']} ကျပ်', style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
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

// -------------------------------------------------------------
// 4. Wallet Tab (ငွေသွင်း/ငွေထုတ် စီမံခန့်ခွဲမှု Screen)
// -------------------------------------------------------------
class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  final TextEditingController _amountController = TextEditingController();

  void _depositMoney() async {
    double? amt = double.tryParse(_amountController.text);
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ငွေပမာဏ မှန်ကန်စွာ ထည့်ပါ')));
      return;
    }
    setState(() {
      UserData.balance += amt;
    });
    await UserData.saveData();
    _amountController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ငွေသွင်းခြင်း တောင်းဆိုမှု အောင်မြင်ပါသည်။ (${amt} ကျပ်)'), backgroundColor: Colors.green),
    );
  }

  void _withdrawMoney() async {
    double? amt = double.tryParse(_amountController.text);
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ငွေပမာဏ မှန်ကန်စွာ ထည့်ပါ')));
      return;
    }
    if (amt > UserData.balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('လက်ကျန်ငွေ ထက်ကျော်လွန်၍ ထုတ်ယူ၍မရပါ')));
      return;
    }
    setState(() {
      UserData.balance -= amt;
    });
    await UserData.saveData();
    _amountController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ငွေထုတ်ခြင်း တောင်းဆိုမှု အောင်မြင်ပါသည်။ (${amt} ကျပ်)'), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ငွေစာရင်း (Wallet & Profile)', style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent),
              ),
              child: Column(
                children: [
                  const Text('လက်ရှိ လက်ကျန်ငွေ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${UserData.balance.toStringAsFixed(2)} ကျပ်', style: const TextStyle(color: Colors.greenAccent, fontSize: 26, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'ငွေပမာဏ ထည့်ရန် (ကျပ်)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: _depositMoney,
                    child: const Text('ငွေသွင်းမည်', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: _withdrawMoney,
                    child: const Text('ငွေထုတ်မည်', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
