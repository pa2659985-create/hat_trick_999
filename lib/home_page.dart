import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberHomePage extends StatelessWidget {
  final String username; // ဝင်ရောက်ထားသော Member ၏ Username (သို့မဟုတ်) UID

  const MemberHomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('မန်ဘာ ပင်မစာမျက်နှာ'),
        backgroundColor: const Color(0xFF132E1B),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1B12),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          // Firestore မှ အဆိုပါ username/UID ဖြင့် Data ကို တိုက်ရိုက် Realtime ဆွဲထုတ်ခြင်း
          stream: FirebaseFirestore.instance.collection('users').doc(username).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('အမှားအယွင်း ရှိနေပါသည်: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
              );
            }

            if (!snapshot.hasData || !snapshot.exists) {
              return const Center(
                child: Text('အချက်အလက် ရှာမတွေ့ပါ။', style: TextStyle(color: Colors.grey)),
              );
            }

            // Cloud Firestore မှ ရလာသော Data များကို ယူသုံးခြင်း
            var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            String displayName = userData['displayName'] ?? username;
            double balance = (userData['balance'] ?? 0.0).toDouble();
            int points = userData['points'] ?? 0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ကြိုဆိုခြင်း Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132E1B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade700),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('မင်္ဂလာပါ၊', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'အကောင့်အမည်: $username',
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ငွေစာရင်းနှင့် ပွိုင့်ပြသသည့် Card (Cloud မှ တိုက်ရိုက် Update ဖြစ်မည်)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132E1B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade800),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('လက်ကျန်ငွေ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(
                                '${balance.toStringAsFixed(2)} Ks',
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132E1B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade800),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text('ပွိုင့်များ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  SizedBox(width: 4),
                                  Icon(Icons.star, color: Colors.amberAccent, size: 14),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$points Pts',
                                style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

