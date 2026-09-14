  Future<void> fetchMatches() async {
    final url = Uri.parse('https://api.football-data.org/v4/matches');
    
    try {
      final response = await http.get(
        url,
        headers: {
          // ဒီနေရာမှာ သင့်ရဲ့ API Key ကို ထည့်ပါ
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

