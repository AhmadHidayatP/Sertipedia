import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerLayout extends StatefulWidget {
  const DrawerLayout({super.key});

  @override
  State<DrawerLayout> createState() => _DrawerLayoutState();
}

class _DrawerLayoutState extends State<DrawerLayout> {
  int _idLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadUserLevel();
  }

  Future<void> _loadUserLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idLevel =
          prefs.getInt('id_level') ?? 0; // Default to 0 if no value found
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF0B2F9F),
        child: ListView(
          padding: const EdgeInsets.only(top: 0),
          children: <Widget>[
            SizedBox(
              height: 89,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF0B2F9F),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (_idLevel == 2 || _idLevel == 3)
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title:
                    const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/homepage');
                },
              ),
            if (_idLevel == 2 || _idLevel == 3)
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Profile',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            if (_idLevel == 2)
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.white),
                title: const Text('Statistik',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/statistik');
                },
              ),
            if (_idLevel == 2)
              ExpansionTile(
                leading: const Icon(Icons.check_circle, color: Colors.white),
                title: const Text('Verifikasi',
                    style: TextStyle(color: Colors.white)),
                children: [
                  ListTile(
                    title: const Text('Sertifikasi',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/verifikasi_sertifikasi');
                    },
                  ),
                  ListTile(
                    title: const Text('Pelatihan',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/verifikasi_pelatihan');
                    },
                  ),
                ],
              ),
            if (_idLevel == 2)
              ListTile(
                leading: const Icon(Icons.school, color: Colors.white),
                title: const Text('Kompetensi Prodi',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/kompetensi_prodi');
                },
              ),
            if (_idLevel == 2 || _idLevel == 3)
              ExpansionTile(
                leading:
                    const Icon(Icons.workspace_premium, color: Colors.white),
                title: const Text('Input Data',
                    style: TextStyle(color: Colors.white)),
                children: [
                  ListTile(
                    title: const Text('Sertifikasi',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/user_sertifikasi');
                    },
                  ),
                  ListTile(
                    title: const Text('Pelatihan',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/user_pelatihan');
                    },
                  ),
                ],
              ),
            if (_idLevel == 2 || _idLevel == 3)
              ListTile(
                leading:
                    const Icon(Icons.notifications_active, color: Colors.white),
                title: const Text('Notifikasi',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/notifikasi');
                },
              ),
            // if (_idLevel == 2 || _idLevel == 3)
            //   ListTile(
            //     leading: const Icon(Icons.file_download,
            //         color: Colors.white), // Icon for Download Surat
            //     title: const Text('Download Surat',
            //         style: TextStyle(color: Colors.white)),
            //     onTap: () {
            //       Navigator.pop(context);
            //       Navigator.pushNamed(
            //           context, '/surat_tugas'); // Navigate to Login on logout
            //     },
            //   ),
            if (_idLevel == 0)
              ListTile(
                leading: const Icon(Icons.login, color: Colors.white),
                title:
                    const Text('Login', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.pushNamed(context, '/login');
                },
              ),
            if (_idLevel == 2 || _idLevel == 3)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context); // Close the drawer

                  // Tampilkan popup konfirmasi logout
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin logout?'),
                        actionsAlignment: MainAxisAlignment
                            .spaceBetween, // Atur posisi tombol
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              // Lanjutkan proses logout jika pengguna memilih Ya
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs
                                  .clear(); // Menghapus semua data yang tersimpan

                              // Navigasi ke halaman login
                              Navigator.of(context).pop(); // Tutup dialog
                              Navigator.pushReplacementNamed(context, '/login');

                              print('User logged out and data cleared.');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Ya',
                              style: TextStyle(
                                  color: Colors.white), // Teks berwarna putih
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Tutup dialog jika pengguna memilih Batal
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue, // Warna biru untuk tombol Batal
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                  color: Colors.white), // Teks berwarna putih
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
