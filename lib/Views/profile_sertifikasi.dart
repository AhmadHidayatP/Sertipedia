import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:dio/dio.dart'; // Import Dio for HTTP requests
import 'package:sertipedia/Api/api_services.dart'; // Import API services

class ProfileSertifikasiPage extends StatefulWidget {
  const ProfileSertifikasiPage({super.key, required this.title});
  final String title;

  @override
  State<ProfileSertifikasiPage> createState() => _ProfileSertifikasiPageState();
}

class _ProfileSertifikasiPageState extends State<ProfileSertifikasiPage> {
  late int _idUser;
  String searchQuery = '';
  List<Map<String, String>> sertifikasiData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    _idUser = arguments['id_user'] ?? 0;

    fetchSertifikasiData(); // Fetch certification data
  }

  Future<void> fetchSertifikasiData() async {
    try {
      final url = url_user_data_sertifikasi +
          _idUser.toString(); // API URL to fetch certification data
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        var sertifikasi = response.data['sertifikasi'];

        if (sertifikasi is List) {
          setState(() {
            sertifikasiData = sertifikasi.map<Map<String, String>>((item) {
              return {
                'nama_sertifikasi': item['nama_sertifikasi'] ?? '',
                'nama_vendor': item['nama_vendor'] ?? '',
                'jenis_sertifikasi': item['jenis_sertifikasi'] ?? '',
                'tahun': item['tahun'] ?? '',
              };
            }).toList();
          });
        }
      } else {
        print('Failed to fetch certification data');
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
            Navigator.pop(context); // Navigate back to the previous screen
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
              'assets/backgroundbuttom.png', // Path to your footer image
              fit: BoxFit.cover,
              height: 110, // Adjust the height if necessary
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
                        'Data Sertifikasi Dimiliki',
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
                sertifikasiData.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Pengguna Ini Belum Memiliki Sertifikasi',
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
                              DataColumn(label: Text('Nama Sertifikasi')),
                              DataColumn(label: Text('Vendor')),
                              DataColumn(label: Text('Jenis Sertifikasi')),
                              DataColumn(label: Text('Tahun')),
                            ],
                            rows: sertifikasiData
                                .where((item) =>
                                    item['nama_sertifikasi']!
                                        .toLowerCase()
                                        .contains(searchQuery) ||
                                    item['nama_vendor']!
                                        .toLowerCase()
                                        .contains(searchQuery))
                                .map(
                                  (item) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(item['nama_sertifikasi']!)),
                                      DataCell(Text(item['nama_vendor']!)),
                                      DataCell(
                                          Text(item['jenis_sertifikasi']!)),
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
