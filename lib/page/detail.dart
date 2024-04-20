import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailPage extends StatefulWidget {
  final String suratId;
  final String suratTitle;
  final String suratTitleArab;
  final String arti;
  final String tempatTurun;
  final String jumlahAyat;

  const DetailPage({
    super.key,
    required this.suratId,
    required this.suratTitle,
    required this.suratTitleArab,
    required this.arti,
    required this.tempatTurun,
    required this.jumlahAyat,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<dynamic> ayats = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAyat(widget.suratId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('${widget.suratTitle} ${widget.suratTitleArab}'),
              background: Image.network(
                'https://source.unsplash.com/featured/?islam',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah Ayat: ${widget.jumlahAyat}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Arti: ${widget.arti}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tempat Turun: ${widget.tempatTurun}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ayat = ayats[index];
                final teksArab = ayat['teksArab'];
                final teksIndo = ayat['teksLatin'];
                final arti = ayat['teksIndonesia'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            teksArab,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                teksIndo,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                arti,
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],
                );
              },
              childCount: ayats.length,
            ),
          ),
        ],
      ),
    );
  }

  void fetchAyat(String nomorSurat) async {
    setState(() {
      isLoading = true;
    });

    String url = 'https://equran.id/api/v2/surat/$nomorSurat';

    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);

        // Pastikan struktur respons sesuai dengan yang Anda harapkan
        if (json['data'] != null && json['data']['ayat'] is List) {
          List<dynamic> ayatData = json['data']['ayat'];

          setState(() {
            ayats = ayatData;
            isLoading = false;
          });

          print('Fetch ayats Complete');
        } else {
          print('Failed to fetch ayats: Data structure is incorrect');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch ayats: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching ayats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
}
