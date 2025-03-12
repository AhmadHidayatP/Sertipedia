import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart'; // Import DataTable2
import 'package:sertipedia/Template/drawer.dart';
import 'package:sertipedia/Api/api_services.dart';

class KompetensiProdi extends StatefulWidget {
  const KompetensiProdi({super.key, required this.title});
  final String title;

  @override
  State<KompetensiProdi> createState() => _KompetensiProdiState();
}

class _KompetensiProdiState extends State<KompetensiProdi> {
  String _searchQuery = ""; // Variable to hold search query
  List<Map<String, String>> _data = []; // Data fetched from kompetensi API
  Map<String, String> _prodiMap = {}; // Map to hold id_prodi to prodi_name
  bool _isLoading = true; // Loading state
  bool _hasError = false; // Error state

  // Fetch data from kompetensi and prodi APIs
  Future<void> _fetchData() async {
    try {
      final kompetensiResponse = await http.get(
        Uri.parse(url_kompetensis), // Menggunakan Uri.parse untuk URL kompetensis
      );
      final prodiResponse = await http.get(
        Uri.parse(url_prodis), // Menggunakan Uri.parse untuk URL prodis
      );

      if (kompetensiResponse.statusCode == 200 &&
          prodiResponse.statusCode == 200) {
        final List<dynamic> kompetensiJson =
        json.decode(kompetensiResponse.body) as List<dynamic>;
        final List<dynamic> prodiJson =
        json.decode(prodiResponse.body) as List<dynamic>;

        final Map<String, String> prodiMap = {
          for (var item in prodiJson)
            item['id_prodi'].toString(): item['nama'].toString()
        };

        setState(() {
          _prodiMap = prodiMap;
          _data = kompetensiJson.map((item) {
            return {
              'No': item['id_kompetensi'].toString(),
              'Nama': item['nama'].toString(),
              'Prodi': item['id_prodi'].toString(),
              'Deskripsi': item['deskripsi'].toString(),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data when the widget is initialized
  }

  List<Map<String, String>> _getFilteredData() {
    if (_searchQuery.isEmpty) {
      return _data;
    } else {
      return _data.where((row) {
        return row.values.any((value) =>
            value.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
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
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Kompetensi Prodi',
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
                  child: Align(
                    alignment: Alignment.centerLeft, // Align search box to the left
                    child: SizedBox(
                      width: 180, // Set smaller width for search box
                      height: 40, // Set smaller height for search box
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hasError
                      ? const Center(
                    child: Text(
                      'Error fetching data',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DataTable2(
                          headingRowColor:
                          MaterialStateColor.resolveWith(
                                (states) => const Color(0xFF0B2F9F),
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          columnSpacing: 10.0,
                          horizontalMargin: 10.0,
                          minWidth: 500.0,
                          fixedTopRows: 1,
                          dataRowHeight: 60.0, // Menambahkan tinggi antar baris
                          columns: const [
                            DataColumn2(
                                label: Text('No'),
                                size: ColumnSize.S), // Smaller size
                            DataColumn2(
                                label: Text('Nama'),
                                size: ColumnSize.L),
                            DataColumn2(
                                label: Text('Prodi'),
                                size: ColumnSize.M),
                            DataColumn2(
                                label: Text('Deskripsi'),
                                size: ColumnSize.L),
                          ],
                          rows: _getFilteredData().map((row) {
                            return DataRow(cells: [
                              DataCell(Text(row['No']!, style: const TextStyle(fontSize: 12),)),
                              DataCell(Text(row['Nama']!, style: const TextStyle(fontSize: 12),)),
                              DataCell(Text(
                                _prodiMap[row['Prodi']] ?? 'Unknown', style: const TextStyle(fontSize: 12),)),
                              DataCell(Text(row['Deskripsi']!, style: const TextStyle(fontSize: 12),)),
                            ]);
                          }).toList(),
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