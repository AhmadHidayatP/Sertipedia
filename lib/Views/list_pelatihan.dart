import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:sertipedia/Api/api_services.dart';
import 'package:intl/intl.dart';

class Pelatihan extends StatefulWidget {
  final String title;

  const Pelatihan({required this.title, Key? key}) : super(key: key);

  @override
  _PelatihanState createState() => _PelatihanState();
}

class _PelatihanState extends State<Pelatihan> {
  late Future<Map<String, dynamic>> _pelatihanData;

  @override
  void initState() {
    super.initState();
    _pelatihanData = _fetchPelatihan();
  }

  Future<Map<String, dynamic>> _fetchPelatihan() async {
    final response = await http.get(Uri.parse(url_pelatihan_statistiks));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal Memuat Halaman Pelatihan");
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
                future: _pelatihanData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    final pelatihanList = snapshot.data!['pelatihan'];
                    final dateFormat = DateFormat('dd-MM-yy'); 
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LIST PELATIHAN',
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
                                          label: Text('Nama Pelatihan',
                                              style: TextStyle(color: Colors.white))),
                                      DataColumn(
                                          label: Text('Vendor',
                                              style: TextStyle(color: Colors.white))),
                                      DataColumn(
                                          label: Text('Level Pelatihan',
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
                                    rows: List.generate(pelatihanList.length, (index) {
                                      final pelatihan = pelatihanList[index];
                                      final vendor = pelatihan['vendor']['nama'];
                                      final level = pelatihan['level_pelatihan'];

                                      // Parse and format the date
                                      final tanggalAwal =
                                          DateTime.parse(pelatihan['tanggal_awal']);
                                      final tanggalAkhir = DateTime.parse(pelatihan['tanggal_akhir']);
                                      final formattedTanggalAwal =
                                          dateFormat.format(tanggalAwal);
                                      final formattedTanggalAkhir =
                                          dateFormat.format(tanggalAkhir);

                                      final biaya = pelatihan['biaya'];

                                      return DataRow(
                                        cells: [
                                          DataCell(Text('${index + 1}')),
                                          DataCell(Text(pelatihan['nama'])),
                                          DataCell(Text(vendor)),
                                          DataCell(Text(level)),
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
