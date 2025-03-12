import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> userList = [];
  List<dynamic> prodiList = [];
  List<dynamic> bidangMinatList = [];
  List<dynamic> mataKuliahList = [];
  List<dynamic> filteredUserList = []; // Menyimpan hasil pencarian

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchProdi();
  }

  Future<void> _fetchUser() async {
    try {
      final response = await Dio().get(url_users);
      if (response.statusCode == 200) {
        setState(() {
          userList = response.data as List;
          filteredUserList = userList; // Menyimpan semua user sebagai data awal
        });

        // Ambil data bidang minat dan mata kuliah untuk setiap user
        for (var user in userList) {
          // Fetch bidang minat
          final bidangMinatResponse =
              await Dio().get('$url_user_bidangminat${user['id_user']}');
          if (bidangMinatResponse.statusCode == 200) {
            setState(() {
              var bidangMinat =
                  List<String>.from(bidangMinatResponse.data['bidangminat']);
              bidangMinatList.add({
                'id_user': user['id_user'],
                'bidangminat': bidangMinat,
              });
            });
          }

          // Fetch mata kuliah
          final mataKuliahResponse =
              await Dio().get('$url_user_matakuliah${user['id_user']}');
          if (mataKuliahResponse.statusCode == 200) {
            setState(() {
              var mataKuliah =
                  List<String>.from(mataKuliahResponse.data['matakuliah']);
              mataKuliahList.add({
                'id_user': user['id_user'],
                'matakuliah': mataKuliah,
              });
            });
          }
        }
      } else {
        print("Gagal memuat data User");
      }
    } catch (e) {
      print("Error saat mengambil data User: $e");
    }
  }

  String getBidangMinat(int userId) {
    final bidangMinat = bidangMinatList.firstWhere(
      (bidangMinat) => bidangMinat['id_user'] == userId,
      orElse: () => null,
    );
    return bidangMinat != null
        ? bidangMinat['bidangminat'].join(", ")
        : 'Bidang minat tidak ditemukan';
  }

  String getMataKuliah(int userId) {
    final mataKuliah = mataKuliahList.firstWhere(
      (mataKuliah) => mataKuliah['id_user'] == userId,
      orElse: () => null,
    );
    return mataKuliah != null
        ? mataKuliah['matakuliah'].join(", ")
        : 'Mata kuliah tidak ditemukan';
  }

  Future<void> _fetchProdi() async {
    try {
      final response = await Dio().get(url_prodis);
      if (response.statusCode == 200) {
        setState(() {
          prodiList = response.data as List;
        });
      } else {
        print("Gagal memuat data Prodi");
      }
    } catch (e) {
      print("Error saat mengambil data prodi: $e");
    }
  }

  String getProdiName(int idProdi) {
    final prodi = prodiList.firstWhere(
      (prodi) => prodi['id_prodi'] == idProdi,
      orElse: () => null,
    );
    return prodi != null ? prodi['nama'] : 'Prodi tidak ditemukan';
  }

  void _filterUsers(String query) {
    setState(() {
      searchQuery = query;
      filteredUserList = userList.where((user) {
        String userName = user['nama']?.toLowerCase() ?? '';
        String userProdi = getProdiName(user['id_prodi']).toLowerCase();
        String userBidangMinat = getBidangMinat(user['id_user']).toLowerCase();
        String userMataKuliah = getMataKuliah(user['id_user']).toLowerCase();
        return userName.contains(query.toLowerCase()) ||
            userProdi.contains(query.toLowerCase()) ||
            userBidangMinat.contains(query.toLowerCase()) ||
            userMataKuliah.contains(query.toLowerCase());
      }).toList();
    });
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
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 17.5)),
          ],
        ),
      ),
      drawer: const DrawerLayout(),
      resizeToAvoidBottomInset:
          false, // Prevent body from resizing above keyboard
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                const Text(
                  'Dosen Jurusan Teknologi Informasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF2F2175),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search..',
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUserList.length,
                    itemBuilder: (context, index) {
                      final user = filteredUserList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    user['id_user'] != null
                                        ? '$url_user_image_profile${user['id_user']}'
                                        : 'assets/default-profile.jpg',
                                  ),
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
                            title: Text(
                              user['nama'] ?? 'Unknown',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              'Prodi: ${getProdiName(user['id_prodi'])}\n'
                              'Bidang Minat: ${getBidangMinat(user['id_user'])}\n'
                              // 'Mata Kuliah: ${getMataKuliah(user['id_user'])}',
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0d6efd),
                                    Color(0xFF4576fd),
                                    Color(0xFF607ffc),
                                    Color(0xFF74888fc),
                                    Color(0xFF8691fc),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  // print('ID yang dikirim: ${user['id_user']}');
                                  Navigator.pushNamed(
                                    context,
                                    '/profile_homepage',
                                    arguments: {
                                      'id_user': user['id_user'],
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.visibility, // Eye icon
                                      color: Colors.white,
                                      size: 16, // Adjusted icon size
                                    ),
                                    const SizedBox(
                                        width:
                                            5), // Add space between icon and text
                                    const Text('Detail'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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