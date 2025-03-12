import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class VerifikasiSertifikasi extends StatefulWidget {
  const VerifikasiSertifikasi({super.key, required this.title});
  final String title;

  @override
  State<VerifikasiSertifikasi> createState() => _VerifikasiSertifikasiState();
}

class _VerifikasiSertifikasiState extends State<VerifikasiSertifikasi> {
  List<Map<String, String>> SertifikasiData = [];
  String searchQuery = '';
  bool isLoading = true; // Add loading state

  final NumberFormat formatRp =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  double parseBiaya(String biaya) {
    return double.tryParse(biaya.replaceAll(',', '.')) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    fetchSertifikasiData();
  }

  Future<void> fetchSertifikasiData() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      final response = await Dio().get(url_verifikasi_sertifikasi);
      if (response.statusCode == 200) {
        var sertifikasi = response.data['sertifikasi'];

        if (sertifikasi is Map) {
          setState(() {
            SertifikasiData = sertifikasi.values.map<Map<String, String>>((item) {
              return {
                'nama_sertifikasi': item['nama_sertifikasi'],
                'nama_vendor': item['nama_vendor'],
                'id_sertifikasi': item['id_sertifikasi'].toString(),
                'jenis_sertifikasi': item['jenis_sertifikasi'],
                'tahun': item['tahun'],
                'biaya': item['biaya'],
              };
            }).toList();
          });
        }
      } else {
        print('Gagal mengambil data Sertifikasi');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        isLoading = false; // End loading
      });
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
                        'Verifikasi Sertifikasi',
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
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : SertifikasiData.isEmpty
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
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: List.generate(
                                    SertifikasiData
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
                                        .length,
                                    (index) {
                                      var item = SertifikasiData
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
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/detail_verifikasi_sertifikasi',
                                              arguments: {
                                                'id_sertifikasi': item['id_sertifikasi'],
                                                'nama_sertifikasi': item['nama_sertifikasi'],
                                                'nama_vendor': item['nama_vendor'],
                                                'jenis_sertifikasi': item['jenis_sertifikasi'],
                                                'tahun': item['tahun'],
                                                'biaya': item['biaya'],
                                              },
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['nama_sertifikasi']!,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Vendor : ${item['nama_vendor']!}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Level    : ${item['jenis_sertifikasi']!}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Biaya    : ${formatRp.format(parseBiaya(item['biaya']!))}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Tahun   : ${item['tahun']!}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        // Color(0xFF0d6efd),
                                                        // Color(0xFF4576fd),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
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
