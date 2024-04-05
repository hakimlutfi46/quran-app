import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> surats = [];
  int selectedJuz = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSurat(selectedJuz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Quran Apps',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<int>(
              value: selectedJuz,
              onChanged: (newValue) {
                setState(() {
                  selectedJuz = newValue!;
                  fetchSurat(selectedJuz);
                });
              },
              items: List.generate(30, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text('Juz ${index + 1}')),
                );
              }),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: surats.length,
                      itemBuilder: (context, index) {
                        final surat = surats[index];
                        final judul = surat['englishName'];
                        final judulArab = surat['name'];
                        final arti = surat['englishNameTranslation'];
                        final jumlmahAyat = surat['numberOfAyahs'];

                        return ListTile(
                          onTap: () {},
                          title: Text('$judul ($judulArab)'),
                          subtitle: Text(arti),
                          trailing: Text('$jumlmahAyat Ayat'),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void fetchSurat(int juz) async {
    setState(() {
      isLoading = true;
    });

    String url = 'https://api.alquran.cloud/v1/juz/$juz/ar.asad';

    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);

        List<dynamic> suratData = json['data']['surahs'].values.toList();

        setState(() {
          surats = suratData;
          isLoading = false;
        });

        print('Fetch Surats Complete');
      } else {
        print('Failed to fetch surats: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching surats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
}
