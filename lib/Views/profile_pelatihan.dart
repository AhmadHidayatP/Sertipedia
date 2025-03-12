import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:dio/dio.dart';
import 'package:sertipedia/Api/api_services.dart';

class ProfilePelatihanPage extends StatefulWidget {
  const ProfilePelatihanPage({super.key, required this.title});
  final String title;

  @override
  State<ProfilePelatihanPage> createState() => _ProfilePelatihanPageState();
}

class _ProfilePelatihanPageState extends State<ProfilePelatihanPage> {
  late int _idUser;
  String searchQuery = '';
  List<Map<String, String>> pelatihanData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    _idUser = arguments['id_user'] ?? 0;

    fetchAdditionalData();
  }

  Future<void> fetchAdditionalData() async {
    try {
      final url = url_user_data_pelatihan + _idUser.toString();
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        var pelatihan = response.data['pelatihan'];

        if (pelatihan is List) {
          setState(() {
            pelatihanData = pelatihan.map<Map<String, String>>((item) {
              return {
                'nama_pelatihan': item['nama_pelatihan'] ?? '',
                'nama_vendor': item['nama_vendor'] ?? '',
                'level_pelatihan': item['level_pelatihan'] ?? '',
                'tahun': item['tahun'] ?? '',
              };
            }).toList();
          });
        }
      } else {
        print('Failed to fetch additional data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2F9F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const Padding(padding: EdgeInsets.only(right: 17.5)),
          ],
        ),
      ),
      drawer: const DrawerLayout(),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/backgroundbuttom.png',
              fit: BoxFit.cover,
              height: 110,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Data Pelatihan Dimiliki',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B2F9F),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      fillColor: Colors.grey[300],
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                // Display message if no data is available
                pelatihanData.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Pengguna Ini Belum Melakukan Pelatihan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(label: Text('Nama Pelatihan')),
                              DataColumn(label: Text('Vendor')),
                              DataColumn(label: Text('Level Pelatihan')),
                              DataColumn(label: Text('Periode')),
                            ],
                            rows: pelatihanData
                                .where((item) =>
                                    item['nama_pelatihan']!
                                        .toLowerCase()
                                        .contains(searchQuery) ||
                                    item['nama_vendor']!
                                        .toLowerCase()
                                        .contains(searchQuery))
                                .map(
                                  (item) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(item['nama_pelatihan']!)),
                                      DataCell(Text(item['nama_vendor']!)),
                                      DataCell(Text(item['level_pelatihan']!)),
                                      DataCell(Text(item['tahun']!)),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }
