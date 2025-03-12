import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:sertipedia/Api/api_services.dart';

class Statistik extends StatefulWidget {
  final String title;

  const Statistik({required this.title, Key? key}) : super(key: key);

  @override
  _StatistikState createState() => _StatistikState();
}

class _StatistikState extends State<Statistik> {
  late Future<Map<String, dynamic>> _statistikData;

  @override
  void initState() {
    super.initState();
    _statistikData = _fetchStatistik();
  }

  Future<Map<String, dynamic>> _fetchStatistik() async {
    final response = await http.get(Uri.parse(url_statistiks));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal Memuat Halaman Statistik");
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
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statistikData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATISTIK SERTIFIKASI DAN PELATIHAN DOSEN JTI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF2F2175),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context,
                                '/homepage'); // Navigasi ke halaman User
                          },
                          child: _buildInfoCard(
                            'Dosen',
                            '${data['userCount']}',
                            Icons.people,
                            Colors.teal,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context,
                                '/list_sertifikasi'); // Navigasi ke halaman Sertifikasi
                          },
                          child: _buildInfoCard(
                            'Sertifikasi',
                            '${data['sertifikasiCount']}',
                            Icons.layers,
                            Colors.blue,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context,
                                '/list_pelatihan'); // Navigasi ke halaman Pelatihan
                          },
                          child: _buildInfoCard(
                            'Pelatihan',
                            '${data['pelatihanCount']}',
                            Icons.widgets,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    _buildBarChart(
                        'Status Sertifikasi',
                        data['chartDataSertifikasi']['labels'],
                        data['chartDataSertifikasi']['datasets'][0]['data'],
                        List<String>.from(data['chartDataSertifikasi']
                            ['datasets'][0]['backgroundColor'])),
                    const SizedBox(height: 30),
                    _buildBarChart(
                        'Status Pelatihan',
                        data['chartDataPelatihan']['labels'],
                        data['chartDataPelatihan']['datasets'][0]['data'],
                        List<String>.from(data['chartDataPelatihan']['datasets']
                            [0]['backgroundColor'])),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
      String title, List labels, List data, List<String> backgroundColors) {
    List<Color> colors = backgroundColors.map((e) => _parseColor(e)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true, // Menampilkan grid horizontal
                drawVerticalLine: false, // Menonaktifkan garis vertikal
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString(),
                          style: const TextStyle(fontSize: 12));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < labels.length) {
                        return Text(labels[index],
                            style: const TextStyle(fontSize: 12));
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: List.generate(data.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data[index].toDouble(),
                      color: colors[index % colors.length], // Adjust color
                      width: 20,
                      borderRadius:
                          BorderRadius.zero, // Remove rounding for square shape
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    final regex = RegExp(r'rgba\((\d+), (\d+), (\d+), ([\d\.]+)\)');
    final match = regex.firstMatch(colorString);
    if (match != null) {
      final r = int.parse(match.group(1)!);
      final g = int.parse(match.group(2)!);
      final b = int.parse(match.group(3)!);
      final a = double.parse(match.group(4)!);
      return Color.fromRGBO(r, g, b, a);
    } else {
      return Colors.transparent; // Default to transparent if invalid
    }
  }
}