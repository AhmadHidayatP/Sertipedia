import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:dio/dio.dart';

class UserSertifikasi extends StatefulWidget {
  const UserSertifikasi({super.key, required this.title});
  final String title;

  @override
  State<UserSertifikasi> createState() => _UserSertifikasiState();
}

class _UserSertifikasiState extends State<UserSertifikasi> {
  int _idUser = 0;

  List<Map<String, String>> UserSertifikasiData = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchUserSertifikasiData();
  }

  // Fungsi untuk memuat data user
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getInt('id_user') ?? 0;
    });
  }

  Future<void> fetchUserSertifikasiData() async {
    try {
      final response = await Dio().get(url_user_sertifikasi);
      if (response.statusCode == 200) {
        var sertifikasi = response.data['sertifikasi'];

        if (sertifikasi is List) {
          setState(() {
            UserSertifikasiData = sertifikasi.where((item) {
              return item['id_user'] == _idUser;
            }).map<Map<String, String>>((item) {
              return {
                'nama_sertifikasi': item['nama_sertifikasi'],
                'nama_vendor': item['nama_vendor'],
                'jenis_sertifikasi': item['jenis_sertifikasi'],
                'tahun': item['tahun'],
                'id_detail_sertifikasi': item['id_detail_sertifikasi'].toString(),
              };
            }).toList();
          });
        }
      } else {
        print('Gagal mengambil data Sertifikasi');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2F9F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
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
              'assets/backgroundbuttom.png', // Path ke gambar footer
              fit: BoxFit.cover,
              height: 110, // Sesuaikan tinggi jika perlu
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
                        'Sertifikasi yang Sedang Diikuti',
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
                // Kolom pencarian
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
                // Menampilkan data dalam tabel atau pesan jika tidak ada data
                Expanded(
                  child: UserSertifikasiData.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak Ada Data Sertifikasi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('No')),
                              DataColumn(label: Text('Nama Sertifikasi')),
                              DataColumn(label: Text('Vendor')),
                              DataColumn(label: Text('Jenis Sertifikasi')),
                              DataColumn(label: Text('Tahun')),
                              DataColumn(label: Text('Detail')),
                            ],
                            rows: List.generate(
                              UserSertifikasiData
                                  .where((item) =>
                                      item['nama_sertifikasi']!
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      item['nama_vendor']!
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      item['jenis_sertifikasi']!
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      item['tahun']!
                                          .toLowerCase()
                                          .contains(searchQuery))
                                  .toList()
                                  .length, (index) {
                                var item = UserSertifikasiData
                                    .where((item) =>
                                        item['nama_sertifikasi']!
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        item['nama_vendor']!
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        item['jenis_sertifikasi']!
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        item['tahun']!
                                            .toLowerCase()
                                            .contains(searchQuery))
                                    .toList()[index];
                                return DataRow(cells: [
                                  DataCell(Text(
                                      '${index + 1}')), // Automatically number the rows
                                  DataCell(Text(item['nama_sertifikasi']!)),
                                  DataCell(Text(item['nama_vendor']!)),
                                  DataCell(Text(item['jenis_sertifikasi']!)),
                                  DataCell(Text(item['tahun']!)),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF0d6efd),
                                              Color(0xFF4576fd),
                                              Color(0xFF607ffc),
                                              Color(0xFF74888fc),
                                              Color(0xFF8691fc),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/input_sertifikasi',
                                              arguments: {
                                                'id_detail_sertifikasi': item['id_detail_sertifikasi'],
                                                'nama_sertifikasi' : item['nama_sertifikasi'],
                                                'nama_vendor' : item['nama_vendor'],
                                                'jenis_sertifikasi' : item['jenis_sertifikasi'],
                                                'tahun' : item['tahun'],
                                              },
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.all(5),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(
                                                Icons.visibility, // Eye icon
                                                color: Colors.white,
                                                size: 16, // Adjusted icon size
                                              ),
                                              SizedBox(width: 5),
                                              Text('Detail'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]);
                              }),
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
