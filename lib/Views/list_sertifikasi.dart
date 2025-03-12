import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:sertipedia/Api/api_services.dart';
import 'package:intl/intl.dart';

class Sertifikasi extends StatefulWidget {
  final String title;

  const Sertifikasi({required this.title, Key? key}) : super(key: key);

  @override
  _SertifikasiState createState() => _SertifikasiState();
}

class _SertifikasiState extends State<Sertifikasi> {
  late Future<Map<String, dynamic>> _sertifikasiData;

  @override
  void initState() {
    super.initState();
    _sertifikasiData = _fetchSertifikasi();
  }

  Future<Map<String, dynamic>> _fetchSertifikasi() async {
    final response = await http.get(Uri.parse(url_sertifikasi_statistiks));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal Memuat Halaman Sertifikasi");
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
            Text(widget.title,
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: Colors.white)),
            Padding(padding: EdgeInsets.only(right: 17.5)),
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

          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _sertifikasiData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    final sertifikasiList = snapshot.data!['sertifikasi'];
                    final dateFormat = DateFormat('dd-MM-yy'); 
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LIST SERTIFIKASI',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF0B2F9F),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(
                                          label: Text('No',
                                              style: TextStyle(color: Colors.white))),
                                      DataColumn(
                                          label: Text('Nama Sertifikasi',
                                              style: TextStyle(color: Colors.white))),
                                      DataColumn(
                                          label: Text('Vendor',
                                              style: TextStyle(color: Colors.white))),
                                      DataColumn(
                                          label: Text('Jenis Sertifikasi',
                                              style: TextStyle(color: Colors.white))),
                                      DataColumn(
                                          label: Text('Tanggal Awal',
                                              style: TextStyle(color: Colors.white))),
                                      DataColumn(
                                          label: Text('Tanggal Akhir',
                                              style: TextStyle(color: Colors.white))),
                                      DataColumn(
                                          label: Text('Biaya',
                                              style: TextStyle(color: Colors.white))),
                                    ],
                                    headingRowColor:
                                        MaterialStateProperty.all(Color(0xFF0B2F9F)),
                                    rows: List.generate(sertifikasiList.length,
                                        (index) {
                                      final sertifikasi = sertifikasiList[index];
                                      final vendor = sertifikasi['vendor']['nama'];
                                      final jenis = sertifikasi['jenis_sertifikasi'];

                                      // Parse and format the date
                                      final tanggalAwal =
                                          DateTime.parse(sertifikasi['tanggal_awal']);
                                      final tanggalAkhir = DateTime.parse(
                                          sertifikasi['tanggal_akhir']);
                                      final formattedTanggalAwal =
                                          dateFormat.format(tanggalAwal);
                                      final formattedTanggalAkhir =
                                          dateFormat.format(tanggalAkhir);

                                      final biaya = sertifikasi['biaya'];

                                      return DataRow(
                                        cells: [
                                          DataCell(Text('${index + 1}')),
                                          DataCell(Text(sertifikasi['nama'])),
                                          DataCell(Text(vendor)),
                                          DataCell(Text(jenis)),
                                          DataCell(Text(formattedTanggalAwal)),
                                          DataCell(Text(formattedTanggalAkhir)),
                                          DataCell(Text('Rp $biaya')),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text("No data available"));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
