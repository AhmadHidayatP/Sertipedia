import 'dart:convert';
// import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:sertipedia/Template/drawer.dart';
import 'package:sertipedia/Api/api_services.dart';
import 'package:dio/dio.dart';

class InputPelatihan extends StatefulWidget {
  const InputPelatihan({super.key, required this.title});
  final String title;

  @override
  State<InputPelatihan> createState() => _InputPelatihanState();
}

class _InputPelatihanState extends State<InputPelatihan> {
  late String _idDetailPelatihan;
  late String _namaPelatihan;
  late String _namaVendor;
  late String _levelPelatihan;
  late String _tahun;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _idDetailPelatihan = arguments ['id_detail_pelatihan'] ?? 0;
    _namaPelatihan = arguments['nama_pelatihan'] ?? 0;
    _namaVendor = arguments['nama_vendor'] ?? 0;
    _levelPelatihan = arguments['level_pelatihan'] ?? 0;
    _tahun = arguments ['tahun'] ?? 0;
  }

  String? _base64Image;

  Future<void> _updateImageToServer() async {
    if (_base64Image != null && _idDetailPelatihan != null) {
      try {
        final url =
            url_d_pelatihan_update + _idDetailPelatihan.toString();
        final response = await Dio().put(
          url,
          data: {
            'image': _base64Image,
          },
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diupload!')),
          );

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data gagal diupload!')),
          );
        }
      } catch (e) {
        print('Error: $e');
        // Display an error message if an exception occurs
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Belum memasukkan gambar!')),
      );
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

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menyimpan data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Call the function to update the image
                await _updateImageToServer();
                // Optionally, show a success message to the user
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Image updated successfully!')),
                // );
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 110, // Adjust as necessary for your image height
              width: double.infinity,
              child: Image.asset(
                'assets/backgroundbuttom.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Input Pelatihan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B2F9F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            children: [
                              const TextSpan(
                                text: 'Nama Pelatihan: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: _namaPelatihan,
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            children: [
                              const TextSpan(
                                text: 'Nama Vendor: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: _namaVendor,
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            children: [
                              const TextSpan(
                                text: 'Level Pelatihan: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: _levelPelatihan,
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            children: [
                              const TextSpan(
                                text: 'Periode: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: _tahun,
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _uploadPhoto,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Pelatihan'),
                ),
                if (_base64Image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Image.memory(
                      base64Decode(_base64Image!),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    _showConfirmationDialog(context);
                  },
                  child: const Text('Simpan Pelatihan'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
