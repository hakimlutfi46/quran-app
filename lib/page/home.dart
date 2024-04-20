import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/page/detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> surats = [];
  List<dynamic> filteredSurats = [];
  bool isLoading = false;
  TextEditingController searchController =
      TextEditingController(); // Controller untuk input search

  @override
  void initState() {
    super.initState();
    fetchSurat();
  }

  @override
  void dispose() {
    searchController.dispose(); // Hapus controller saat widget di dispose
    super.dispose();
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  TextField untuk input search
            TextField(
              controller: searchController,
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                hintText: 'Cari Surat',
                focusColor: Colors.green,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                filterSurats(value);
              },
            ),
            isLoading
                ? const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                    itemCount: filteredSurats.isEmpty
                        ? 1
                        : filteredSurats
                            .length, // Gunakan 1 jika tidak ada hasil
                    itemBuilder: (context, index) {
                      if (filteredSurats.isEmpty) {
                        // Tampilkan jika hasil pencarian kosong
                        return const Center(
                          child: Text(
                            'Tidak ada data',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      final surat = filteredSurats[index];
                      final judul = surat['namaLatin'];
                      final judulArab = surat['nama'];
                      final arti = surat['arti'];
                      final jumlmahAyat = surat['jumlahAyat'];

                      return ListTile(
                        onTap: () {
                          handleSuratTap(
                            context,
                            surat['nomor'].toString(),
                            surat['namaLatin'],
                            surat['nama'],
                            surat['arti'],
                            surat['tempatTurun'],
                            surat['jumlahAyat'].toString(),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            surat['nomor'].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text('$judul ($judulArab)'),
                        subtitle: Text(arti),
                        trailing: Text('$jumlmahAyat Ayat'),
                      );
                    },
                  )),
          ],
        ),
      ),
    );
  }

  void handleSuratTap(
    BuildContext context,
    String suratId,
    String suratTitle,
    String suratTitleArab,
    String arti,
    String tempatTurun,
    String jumlahAyat,
  ) {
    print('Surat ID: $suratId $suratTitle');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          suratId: suratId,
          suratTitle: suratTitle,
          suratTitleArab: suratTitleArab,
          arti: arti,
          tempatTurun: tempatTurun,
          jumlahAyat: jumlahAyat,
        ),
      ),
    );
  }

  void fetchSurat() async {
    setState(() {
      isLoading = true;
    });

    String url = 'https://equran.id/api/v2/surat';

    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);

        if (json['data'] != null && json['data'] is List) {
          List<dynamic> suratData = json['data'];

          setState(() {
            surats = suratData;
            filteredSurats = surats;
            isLoading = false;
          });

          print('Fetch Surats Complete');
        } else {
          print('Failed to fetch surats: Data structure is incorrect');
          setState(() {
            isLoading = false;
          });
        }
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

  void filterSurats(String query) {
    // Jika query kosong, tampilkan semua surah
    if (query.isEmpty) {
      setState(() {
        filteredSurats = surats;
      });
      return;
    }

    // Filter surah berdasarkan nama atau nomor
    List<dynamic> filteredList = surats.where((surat) {
      final judul = surat['namaLatin'].toString().toLowerCase();
      final nomor = surat['nomor'].toString();
      return judul.contains(query.toLowerCase()) || nomor.contains(query);
    }).toList();

    setState(() {
      filteredSurats = filteredList;
    });
  }
}
