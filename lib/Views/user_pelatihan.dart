import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:dio/dio.dart';

class UserPelatihan extends StatefulWidget {
  const UserPelatihan({super.key, required this.title});
  final String title;

  @override
  State<UserPelatihan> createState() => _UserPelatihanState();
}

class _UserPelatihanState extends State<UserPelatihan> {
  int _idUser = 0;

  List<Map<String, String>> UserPelatihanData = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchUserPelatihanData();
  }

  // Fungsi untuk memuat data user
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getInt('id_user') ?? 0;
    });
  }

  Future<void> fetchUserPelatihanData() async {
    try {
      final response = await Dio().get(url_user_pelatihan);
      if (response.statusCode == 200) {
        var pelatihan = response.data['pelatihan'];

        if (pelatihan is List) {
          setState(() {
            UserPelatihanData = pelatihan.where((item) {
              return item['id_user'] == _idUser;
            }).map<Map<String, String>>((item) {
              return {
                'nama_pelatihan': item['nama_pelatihan'],
                'nama_vendor': item['nama_vendor'],
                'level_pelatihan': item['level_pelatihan'],
                'tahun': item['tahun'],
                'id_detail_pelatihan': item['id_detail_pelatihan'].toString(),
              };
            }).toList();
          });
        }
      } else {
        print('Gagal mengambil data Pelatihan');
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
                        'Pelatihan yang Sedang Diikuti',
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
                  child: UserPelatihanData.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak Ada Data Pelatihan',
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
                              DataColumn(label: Text('Nama Pelatihan')),
                              DataColumn(label: Text('Vendor')),
                              DataColumn(label: Text('Level Pelatihan')),
                              DataColumn(label: Text('Tahun')),
                              DataColumn(label: Text('Detail')),
                            ],
                            rows: List.generate(
                              UserPelatihanData
                                  .where((item) =>
                                      item['nama_pelatihan']!
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      item['nama_vendor']!
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      item['level_pelatihan']!
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      item['tahun']!
                                          .toLowerCase()
                                          .contains(searchQuery))
                                  .toList()
                                  .length, (index) {
                                var item = UserPelatihanData
                                    .where((item) =>
                                        item['nama_pelatihan']!
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        item['nama_vendor']!
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        item['level_pelatihan']!
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        item['tahun']!
                                            .toLowerCase()
                                            .contains(searchQuery))
                                    .toList()[index];
                                return DataRow(cells: [
                                  DataCell(Text(
                                      '${index + 1}')), // Automatically number the rows
                                  DataCell(Text(item['nama_pelatihan']!)),
                                  DataCell(Text(item['nama_vendor']!)),
                                  DataCell(Text(item['level_pelatihan']!)),
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
                                              '/input_pelatihan',
                                              arguments: {
                                                'id_detail_pelatihan': item['id_detail_pelatihan'],
                                                'nama_pelatihan' : item['nama_pelatihan'],
                                                'nama_vendor' : item['nama_vendor'],
                                                'level_pelatihan' : item['level_pelatihan'],
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
