import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class Notifikasi extends StatefulWidget {
  const Notifikasi({super.key, required this.title});
  final String title;

  @override
  State<Notifikasi> createState() => _NotifikasiState();
}

class _NotifikasiState extends State<Notifikasi> {
  int _idUser = 0;
  String _searchQuery = "";
  List<dynamic> combinedData = []; // Gabungan pelatihan dan sertifikasi
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getInt('id_user') ?? 0;
      print('User ID loaded: $_idUser');
      fetchAllData();
    });
  }

  Future<void> fetchAllData() async {
    try {
      // Ambil data pelatihan
      String urlPelatihan = url_notifikasi_showPelatihan + _idUser.toString();
      Response responsePelatihan = await Dio().get(urlPelatihan);

      List<dynamic> pelatihan = [];
      if (responsePelatihan.statusCode == 200) {
        pelatihan = responsePelatihan.data['data']
            .where((item) =>
                item['status'] != "Rejected" && item['status'] != "Completed")
            .map((item) {
          return {
            "nama_event": item['nama_pelatihan'],
            "vendor": item['nama_vendor'],
            "jenis_level_event": item['level_pelatihan'],
            "tahun": item['tahun'],
            "status": item['status'],
            "surat_tugas": item['surat_tugas'] ?? "Belum Ada Surat Tugas",
            "kategori": "Pelatihan",
          };
        }).toList();
      }

      // Ambil data sertifikasi
      String urlSertifikasi =
          url_notifikasi_showSertifikasi + _idUser.toString();
      Response responseSertifikasi = await Dio().get(urlSertifikasi);

      List<dynamic> sertifikasi = [];
      if (responseSertifikasi.statusCode == 200) {
        sertifikasi = responseSertifikasi.data['data']
            .where((item) =>
                item['status'] != "Rejected" && item['status'] != "Completed")
            .map((item) {
          return {
            "nama_event": item['nama_sertifikasi'],
            "vendor": item['nama_vendor'],
            "jenis_level_event": item['jenis_sertifikasi'],
            "tahun": item['tahun'],
            "status": item['status'],
            "surat_tugas": item['surat_tugas'] ?? "Belum Ada Surat Tugas",
            "kategori": "Sertifikasi",
          };
        }).toList();
      }

      setState(() {
        combinedData = [...pelatihan, ...sertifikasi];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> downloadPDF(String fileName) async {
    try {
      String url = "$url_download_surat$fileName";
      print(url);

      // Meminta izin penyimpanan
      final permissionStatus = await Permission.storage.request();

      if (permissionStatus.isGranted) {
        // Mengunduh file menggunakan Dio
        Dio dio = Dio();
        Response response =
            await dio.download(url, await _getFilePath("Surat_Tugas.pdf"));

        if (response.statusCode == 200) {
          print("Unduhan selesai, file disimpan!");

          // Membuka file yang telah diunduh
          String filePath = await _getFilePath("Surat_Tugas.pdf");
          OpenFile.open(filePath); // Membuka file
        } else {
          print("Gagal mengunduh file, status kode: ${response.statusCode}");
        }
      } else if (permissionStatus.isDenied) {
        // Menangani jika izin penyimpanan ditolak
        openAppSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan ditolak')),
        );
      } else if (permissionStatus.isPermanentlyDenied) {
        // Menangani jika izin penyimpanan permanen ditolak
        print(
            "Izin penyimpanan permanen ditolak. Buka pengaturan aplikasi untuk memberikan izin.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan permanen ditolak')),
        );
        openAppSettings(); // Membuka pengaturan aplikasi untuk memberi izin
      }
    } catch (e) {
      print("Terjadi kesalahan saat mengunduh: $e");
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getExternalStorageDirectory();
    return "${directory!.path}/$fileName";
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
            Text(widget.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: Colors.white)),
            const Padding(padding: EdgeInsets.only(right: 17.5)),
          ],
        ),
      ),
      drawer: const DrawerLayout(),
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
                  child: Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B2F9F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      fillColor: Colors.grey[300],
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? CircularProgressIndicator()
                    : Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('No')),
                              DataColumn(label: Text('Nama Event')),
                              DataColumn(label: Text('Kategori')),
                              DataColumn(label: Text('Vendor')),
                              DataColumn(label: Text('Jenis / Level Event')),
                              DataColumn(label: Text('Tahun')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: combinedData
                                .where((event) =>
                                    event['nama_event']
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    event['kategori']
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    event['vendor']
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    event['jenis_level_event']
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    event['tahun']
                                        .toLowerCase()
                                        .contains(_searchQuery) ||
                                    event['status']
                                        .toLowerCase()
                                        .contains(_searchQuery))
                                .toList()
                                .asMap()
                                .entries
                                .map<DataRow>((entry) {
                              final index = entry.key + 1;
                              final event = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text(index.toString())),
                                  DataCell(Text(event['nama_event'])),
                                  DataCell(Text(event['kategori'])),
                                  DataCell(Text(event['vendor'])),
                                  DataCell(Text(event['jenis_level_event'])),
                                  DataCell(Text(event['tahun'])),
                                  DataCell(
                                    event['status'] == "On Going"
                                        ? ElevatedButton.icon(
                                            onPressed: () {
                                              String fileName =
                                                  event['surat_tugas'];
                                              downloadPDF(fileName);
                                              print(
                                                  'Download Surat Tugas clicked for: ${event['surat_tugas']}');
                                            },
                                            icon: Icon(Icons.download,
                                                color: Colors.white),
                                            label: Text('Download Surat Tugas'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                  0xFF17A2B8), // btn-info color
                                              foregroundColor:
                                                  Colors.white, // Text color
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          )
                                        : Text(event[
                                            'status']), // Default text for other statuses
                                  )
                                ],
                              );
                            }).toList(),
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
