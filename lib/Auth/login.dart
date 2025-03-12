import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sertipedia/Api/api_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Variable to toggle password visibility

  // Login function to authenticate user and store data in SharedPreferences
  Future<void> loginUser() async {
    // API login request URL
    try {
      Dio dio = Dio();
      final response = await dio.post(
        url_login, // Replace with your actual URL
        data: {
          'email': emailController.text,
          'password': passwordController.text,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        var data = response.data;

        // Check if the response is successful
        if (data['success']) {
          // Save user data and token to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id_user', data['user']['id_user']);
          await prefs.setInt('id_level', data['user']['id_level']);
          await prefs.setInt('id_prodi', data['user']['id_prodi']);
          await prefs.setString('nama', data['user']['nama']);
          await prefs.setString('nip', data['user']['nip']);
          await prefs.setString('email', data['user']['email']);
          await prefs.setString('no_telp', data['user']['no_telp']);
          await prefs.setString('email', data['user']['email']);
          await prefs.setString('token', data['token']);

          // Debugging: Print the saved data to the console
          print('Saved Data to SharedPreferences:');
          print('id_user: ${data['user']['id_user']}');
          print('id_level: ${data['user']['id_level']}');
          print('id_prodi: ${data['user']['id_prodi']}');
          print('nama: ${data['user']['nama']}');
          print('email: ${data['user']['email']}');
          print('no_telp: ${data['user']['no_telp']}');
          print('email: ${data['user']['email']}');
          print('token: ${data['token']}');

          // Optionally navigate to another page after successful login
          Navigator.pushReplacementNamed(
              context, '/homepage'); // Change '/home' to your home route
        } else {
          // Handle failed login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Login failed, please check your credentials')),
          );
        }
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to server')),
        );
      }
    } catch (e) {
      // Handle Dio error (e.g., network issues)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again later.')),
      );
      print('Error: $e');
    }
  }

  // Function to check and print the stored SharedPreferences data (for debugging)
  Future<void> checkStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('id_user');
    int? levelId = prefs.getInt('id_level');
    String? email = prefs.getString('email');

    // Debugging: Print the retrieved data
    print('Retrieved Data from SharedPreferences:');
    print('token: $token');
    print('id_user: $userId');
    print('id_level: $levelId');
    print('email: $email');
  }

  //Function to logout
  Future<void> logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear all saved data in SharedPreferences
    await prefs.clear();

    // Debugging: Confirm the data is cleared
    print('User logged out. All data cleared from SharedPreferences.');

    // Navigate back to the login page
    Navigator.pushReplacementNamed(context, '/login'); // Ganti '/login' sesuai dengan route halaman login Anda
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2F9F),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/backgroundtop.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(padding: EdgeInsets.only(bottom: 50)),
                  const Text(
                    'Selamat Datang!',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sistem Informasi Sertifikasi\ndan Pelatihan Dosen JTI\n\n\n',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible, // Manage visibility here
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: loginUser, // Call the login function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D9D9),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF0B2F9F),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the Mahasiswa homepage route
                        Navigator.pushNamed(context, '/homepage');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Log in sebagai Mahasiswa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}