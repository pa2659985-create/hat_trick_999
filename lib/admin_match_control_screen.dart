import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMatchControlScreen extends StatefulWidget {
  const AdminMatchControlScreen({super.key});

  @override
  State<AdminMatchControlScreen> createState() => _AdminMatchControlScreenState();
}

class _AdminMatchControlScreenState extends State<AdminMatchControlScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _homeTeamController = TextEditingController();
  final TextEditingController _awayTeamController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _leagueController = TextEditingController();

  // Firestore သို့ ပွဲစဉ်အသစ် ထည့်သွင်းခြင်း
  Future<void> _addMatch() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('matches').add({
          'homeTeam': _homeTeamController.text.trim(),
          'awayTeam': _awayTeamController.text.trim(),
          'matchTime': _timeController.text.trim(),
          'league': _leagueController.text.trim(),
          'status': 'Upcoming', // Upcoming, Live, Finished
          'homeScore': 0,
          'awayScore': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _homeTeamController.clear();
        _awayTeamController.clear();
        _timeController.clear();
        _leagueController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ပွဲစဉ်အသစ် အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ။'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('အမှားအယွင်း ဖြစ်ပေါ်သည်: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ပွဲစဉ် ဖျက်ရန်
  Future<void> _deleteMatch(String matchId) async {
    await FirebaseFirestore.instance.collection('matches').doc(matchId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - ပွဲစဉ်များ စီမံခန့်ခွဲရန်'),
        backgroundColor: const Color(0xFF132E1B),
      ),
      body: Container(
        color: const Color(0xFF0D1B12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ပွဲစဉ်အသစ်ထည့်ရန် Form
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ပွဲစဉ်အသစ် ထည့်ရန်', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _leagueController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'လိဂ်အမည် (ဥပမာ - Premier League)',
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                          ),
                          validator: (value) => value!.isEmpty ? 'လိဂ်အမည် ထည့်ပါ။' : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _homeTeamController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'အိမ်ရှင်အသင်း',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                                ),
                                validator: (value) => value!.isEmpty ? 'အိမ်ရှင်အသင်းထည့်ပါ။' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _awayTeamController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'ဧည့်သည်အသင်း',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                                ),
                                validator: (value) => value!.isEmpty ? 'ဧည့်သည်အသင်းထည့်ပါ။' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _timeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'ပွဲချိန် (ဥပမာ - 08:00 PM)',
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                          ),
                          validator: (value) => value!.isEmpty ? 'ပွဲချိန်ထည့်ပါ။' : null,
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addMatch,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                            child: const Text('ပွဲစဉ် သိမ်းဆည်းရန်', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.green, thickness: 1),
              
              // လက်ရှိထည့်ထားသော ပွဲစဉ်များစာရင်းကို Realtime ပြသခြင်း
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('လက်ရှိ ပွဲစဉ်များစာရင်း', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 3,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('matches').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('ပွဲစဉ်များ မရှိသေးပါ။', style: TextStyle(color: Colors.grey)));
                    }

                    var matches = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        var match = matches[index];
                        var data = match.data() as Map<String, dynamic>;

                        return Card(
                          color: const Color(0xFF132E1B),
                          child: ListTile(
                            title: Text(
                              '${data['homeTeam']} vs ${data['awayTeam']}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'လိဂ်: ${data['league']} | အချိန်: ${data['matchTime']}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(cols: [], color: Colors.redAccent, icon: Icons.delete), // icon bug fix below
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteMatch(match.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
