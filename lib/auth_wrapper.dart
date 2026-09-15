import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart'; // Member ပင်မစာမျက်နှာ
import 'login_page.dart'; // Login စာမျက်နှာ

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Connection စောင့်နေစဉ် Loading ပြရန်
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // အကောင့်ဝင်ထားပြီးသားဆိုလျှင် HomePage သို့သွားမည်
        if (snapshot.hasData) {
          return const HomePage();
        }

        // မဝင်ရသေးပါက (သို့မဟုတ်) ထွက်သွားပါက LoginPage သို့သွားမည်
        return const LoginPage();
      },
    );
  }
}
