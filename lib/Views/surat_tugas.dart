import 'package:flutter/material.dart';
import 'package:sertipedia/Template/drawer.dart';

class SuratTugasPage extends StatefulWidget {
  const SuratTugasPage({super.key, required this.title});
  final String title;

  @override
  State<SuratTugasPage> createState() => _SuratTugasPageState();
}

class _SuratTugasPageState extends State<SuratTugasPage> {
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
              Text(widget.title, // Gunakan title yang diteruskan dari route
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.white)),
              Padding(padding: EdgeInsets.only(right: 17.5)),
            ],
          ),
        ),
        drawer: const DrawerLayout(),
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(bottom: 30.0)),
                    const Text(
                      'PROFILE',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 40.0),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFF0D6EFD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to main page on button press
                        },
                        child: const Text(
                          "Download",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset('assets/backgroundbuttom.png',
                  fit: BoxFit.cover, width: double.infinity, height: 110),
            ),
          ],
        ));
  }
}
