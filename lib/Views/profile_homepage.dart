import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:dio/dio.dart';

class ProfileHomepage extends StatefulWidget {
  const ProfileHomepage({super.key, required this.title});
  final String title;

  @override
  State<ProfileHomepage> createState() => _ProfileHomepageState();
}

class _ProfileHomepageState extends State<ProfileHomepage> {
  late int _idUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    _idUser = arguments['id_user'] ?? 0;

    fetchAdditionalData();

    // print('User ID: $_idUser');
  }

  // Additional variables to store user data
  String _namaUser = '';
  String _emailUser = '';
  String _namaLevel = '';
  String _namaProdi = '';
  String _namaPangkat = '';
  String _namaGolongan = '';
  String _namaJabatan = '';

  Future<void> fetchAdditionalData() async {
    try {
      final url = url_user_data_profile + _idUser.toString();
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        setState(() {
          _namaUser = response.data['user']['nama'] ?? 'Nama Tidak Tersedia';
          _emailUser = response.data['user']['email'] ?? 'Email Tidak Tersedia';
          _namaLevel = response.data['nama_level'] ?? 'Level Tidak Tersedia';
          _namaProdi = response.data['nama_prodi'] ?? 'Prodi Tidak Tersedia';
          _namaPangkat =
              response.data['nama_pangkat'] ?? 'Pangkat Tidak Tersedia';
          _namaGolongan =
              response.data['nama_golongan'] ?? 'Golongan Tidak Tersedia';
          _namaJabatan =
              response.data['nama_jabatan'] ?? 'Jabatan Tidak Tersedia';
        });
      } else {
        print('Failed to fetch additional data');
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
            Text(widget.title,
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: Colors.white)),
            Padding(padding: EdgeInsets.only(right: 17.5)),
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: DecorationImage(
                                    image: _idUser > 0
                                        ? NetworkImage(
                                            url_user_image_profile +
                                                _idUser.toString(),
                                            scale: 1.0)
                                        : AssetImage(
                                                'assets/default-profile.jpg')
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _namaUser,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Text(_emailUser,
                            style: TextStyle(color: Colors.black54)),
                        
                        const SizedBox(height: 20),
                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D6EFD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  print('ID yang dikirim: $_idUser');
                                  Navigator.pushNamed(
                                    context,
                                    '/profile_sertifikasi',
                                    arguments: {'id_user': _idUser},
                                  );
                                },
                                child: const Text(
                                  "Sertifikasi",
                                  style: TextStyle(
                                    color: Colors.white, // Teks warna putih
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D6EFD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  print('ID yang dikirim: $_idUser');
                                  Navigator.pushNamed(
                                    context,
                                    '/profile_pelatihan',
                                    arguments: {'id_user': _idUser},
                                  );
                                },
                                child: const Text(
                                  "Pelatihan",
                                  style: TextStyle(
                                    color: Colors.white, // Teks warna putih
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildNonEditableField("Nama", _namaUser, Icons.person),
                  _buildNonEditableField("Email", _emailUser, Icons.email),
                  _buildNonEditableField(
                      "Level", _namaLevel, Icons.account_circle),
                  _buildNonEditableField("Prodi", _namaProdi, Icons.school),
                  _buildNonEditableField("Pangkat", _namaPangkat, Icons.star),
                  _buildNonEditableField(
                      "Golongan", _namaGolongan, Icons.group),
                  _buildNonEditableField("Jabatan", _namaJabatan, Icons.work),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonEditableField(String label, String value, IconData iconData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(iconData, color: Colors.grey), // Menampilkan ikon
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }
}
