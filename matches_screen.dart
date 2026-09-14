Future<void> fetchMatches() async {
    // ယနေ့ရက်စွဲနှင့် လာမည့် ၃ ရက်စာ ပွဲစဉ်များကိုပါ တစ်ခါတည်း ဆွဲထုတ်ရန် dateFrom နှင့် dateTo ကို သုံးပါ
    // (သို့မဟုတ်) လိုချင်သော ရက်စွဲအလိုက် ပြောင်းလဲနိုင်ပါသည်
    final String today = '2026-09-14'; // လိုအပ်ပါက Dynamic ရက်စွဲသုံးနိုင်ပါသည်
    final String endDate = '2026-09-17';
    
    // Free Tier တွင် ပွဲစဉ်များ ပိုစုံစေရန် အဓိကလိဂ်ကြီးများ၏ ID များကို ထည့်သွင်းနိုင်သည် (ဥပမာ- Premier League, La Liga, Champions League)
    final url = Uri.parse('https://api.football-data.org/v4/matches?dateFrom=$today&dateTo=$endDate');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'X-Auth-Token': '5a87133d1c764efb8525d81e82d605fd',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          matches = data['matches'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
}
