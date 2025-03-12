import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class DetailVerifikasiPelatihan extends StatefulWidget {
  const DetailVerifikasiPelatihan({super.key, required this.title});
  final String title;

  @override
  State<DetailVerifikasiPelatihan> createState() =>
      _DetailVerifikasiPelatihanState();
}

class _DetailVerifikasiPelatihanState extends State<DetailVerifikasiPelatihan> {
  late String _idPelatihan;
  late String _namaPelatihan;
  late String _namaVendor;
  late String _levelPelatihan;
  late String _tahun;
  late String _biaya;
  List<Map<String, dynamic>> users = [];
  final NumberFormat formatRp =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _idPelatihan = arguments['id_pelatihan'] ?? 0;
    _namaPelatihan = arguments['nama_pelatihan'] ?? 0;
    _namaVendor = arguments['nama_vendor'] ?? 0;
    _levelPelatihan = arguments['level_pelatihan'] ?? 0;
    _tahun = arguments['tahun'] ?? 0;
    _biaya = arguments['biaya'] ?? 0;

    fetchUserByPelatihan();
  }

  Future<void> fetchUserByPelatihan() async {
    try {
      final url = url_user_byPelatihan + _idPelatihan.toString();
      Dio dio = Dio();
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response.data['data']);
        });
        print('Fetched users data: $users');
      } else {
        _showAlertDialog(
            context, "Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      _showAlertDialog(context, "Error: $e");
    }
  }

  void _updateStatus(String status) async {
    try {
      final url = url_change_status_pelatihan + _idPelatihan.toString();
      print(url);
      Dio dio = Dio();
      Response response = await dio.put(
        url,
        data: {
          'id_pelatihan': _idPelatihan,
          'status': status,
        },
      );
      if (response.statusCode == 200) {
        _showAlertDialog(context, "Status berhasil diperbarui menjadi $status");
        fetchUserByPelatihan();
      } else {
        _showAlertDialog(
            context, "Gagal memperbarui status: ${response.statusCode}");
      }
    } catch (e) {
      _showAlertDialog(context, "Error: $e");
    }
  }

  void _showConfirmationDialog(BuildContext context, String action) {
    String status = action == 'menyetujui data' ? 'Accepted' : 'Rejected';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin $action?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _updateStatus(status);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Peringatan"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white)),
          ],
        ),
        elevation: 8,
      ),
      drawer: const DrawerLayout(),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              width: double.infinity,
              child: Image.asset(
                'assets/backgroundbuttom.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pelatihan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_namaPelatihan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vendor : $_namaVendor',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Jenis    : $_levelPelatihan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Biaya    : ${formatRp.format(double.tryParse(_biaya) ?? 0)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tahun   : $_tahun',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Peserta Pelatihan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/profile_homepage',
                            arguments: {
                              'id_user': user['id_user'],
                            },
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipOval(
                                child: Container(
                                  width: 55.0,
                                  height: 55.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        user['id_user'] != null
                                            ? '$url_user_image_profile${user['id_user']}'
                                            : 'assets/default-profile.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  user['nama'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(context, 'menolak data');
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      backgroundColor: Colors.red,
                      elevation: 6,
                    ),
                    child: Text(
                      'Tolak',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(context, 'menyetujui data');
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      backgroundColor: Colors.green,
                      elevation: 6,
                    ),
                    child: Text(
                      'Setuju',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
