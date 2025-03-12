import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.title});
  final String title;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _idUser = 0;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _nipController = TextEditingController();

  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  String? _base64Image;
  String _namaLevel = '';
  String _namaProdi = '';
  String _namaPangkat = '';
  String _namaGolongan = '';
  String _namaJabatan = '';

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nipController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getInt('id_user') ?? 0;
      _nameController.text = prefs.getString('nama') ?? 'Nama Tidak Tersedia';
      _emailController.text =
          prefs.getString('email') ?? 'Email Tidak Tersedia';
      _phoneController.text =
          prefs.getString('no_telp') ?? 'Nomor Telepon Tidak Tersedia';
      _nipController.text =
          prefs.getString('nip') ?? 'NIP Tidak Tersedia';
      // Fetch additional data from API
      fetchAdditionalData();
    });
  }

  Future<void> fetchAdditionalData() async {
    try {
      final url = url_user_data_profile + _idUser.toString();
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        setState(() {
          _namaLevel = response.data['nama_level'] ?? 'Level Tidak Tersedia';
          _namaProdi = response.data['nama_prodi'] ?? 'Prodi Tidak Tersedia';
          _namaPangkat =
              response.data['nama_pangkat'] ?? 'Pangkat Tidak Tersedia';
          _namaGolongan =
              response.data['nama_golongan'] ?? 'Golongan Tidak Tersedia';
          _namaJabatan =
              response.data['nama_jabatan'] ?? 'Jabatan Tidak Tersedia';
          print('Response data: ${response.data}');
        });
      } else {
        print('Failed to fetch additional data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateDataUser() async {
    if (_idUser > 0) {
      // Retrieve current values from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentName = prefs.getString('nama') ?? '';
      String currentEmail = prefs.getString('email') ?? '';
      String currentPhone = prefs.getString('no_telp') ?? '';
      String currentNIP = prefs.getString('nip') ?? '';

      // Prepare the data for the PUT request
      Map<String, dynamic> data = {
        'nama': _nameController.text,
        'email': _emailController.text,
        'no_telp': _phoneController.text,
        'nip': _nipController.text,
        'image': _base64Image,
      };
      if (_oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty) {
        if (_oldPasswordController.text == _newPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Password baru tidak boleh sama dengan password lama')),
          );
          return; // Exit the function if passwords are the same
        }
        data['old_password'] = _oldPasswordController.text;
        data['new_password'] = _newPasswordController.text;
      }

      // Check if no changes have been made in other fields, and if no password is provided, show message
      bool noChanges = (_nameController.text == currentName &&
          _emailController.text == currentEmail &&
          _phoneController.text == currentPhone &&
          _nipController.text == currentNIP &&
          _base64Image == null);

      // If no changes and no password update, show message and exit
      if (noChanges &&
          _oldPasswordController.text.isEmpty &&
          _newPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data yang diperbarui')),
        );
        return; // Exit without making the update request
      }

      try {
        final url = url_user_update + _idUser.toString();
        print('Data being sent: $data');

        final response = await Dio().put(
          url,
          data: data,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diupdate')),
          );

          // Update SharedPreferences with the new values
          await prefs.setString('nama', _nameController.text);
          await prefs.setString('email', _emailController.text);
          await prefs.setString('no_telp', _phoneController.text);
          await prefs.setString('nip', _nipController.text);

          // Update the state to reflect the changes
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal melakukan update!')),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No data to update.');
    }
  }

  Future<void> _uploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Upload Photo"),
          content: const Text("Choose your source"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  final bytes = await pickedFile.readAsBytes();
                  setState(() {
                    _base64Image = base64Encode(bytes);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () async {
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final bytes = await pickedFile.readAsBytes();
                  setState(() {
                    _base64Image = base64Encode(bytes);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Gallery"),
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
                            IconButton(
                              onPressed: _uploadPhoto,
                              icon: const Icon(Icons.edit,
                                  color: Colors.black, size: 30),
                              padding: EdgeInsets.all(10),
                              constraints: BoxConstraints(),
                              iconSize: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _nameController.text,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        Text(_emailController.text,
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
                  _buildInputField("Nama", Icons.person, _nameController),
                  _buildInputField("Email", Icons.email, _emailController),
                  _buildInputField("No Telepon", Icons.phone, _phoneController),
                  _buildInputField(
                      "nip", Icons.account_circle, _nipController),
                  _buildPasswordField("Old Password", _oldPasswordController,
                      _isOldPasswordVisible),
                  _buildPasswordField("New Password", _newPasswordController,
                      _isNewPasswordVisible),
                  const SizedBox(height: 30),
                  _buildNonEditableField(
                      "Level", _namaLevel, Icons.account_circle),
                  _buildNonEditableField("Prodi", _namaProdi, Icons.school),
                  _buildNonEditableField("Pangkat", _namaPangkat, Icons.star),
                  _buildNonEditableField(
                      "Golongan", _namaGolongan, Icons.group),
                  _buildNonEditableField("Jabatan", _namaJabatan, Icons.work),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(0xFF0D6EFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      _updateDataUser();
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white, fontSize: 18),
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

// Modify the _buildInputField to take a TextEditingController as a parameter
  Widget _buildInputField(
      String hintText, IconData icon, TextEditingController? controller) {
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
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller, bool isVisible) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                // Toggle the visibility state
                if (label == "Old Password") {
                  _isOldPasswordVisible = !_isOldPasswordVisible;
                } else if (label == "New Password") {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                }
              });
            },
          ),
          border: const OutlineInputBorder(),
          filled: true, // Enable filling
          fillColor: Colors.white, // Set background color to white
        ),
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
          prefixIcon: Icon(iconData, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }
}
