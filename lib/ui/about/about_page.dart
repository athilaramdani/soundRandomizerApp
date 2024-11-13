import 'dart:ui';
import 'package:athdan2/function.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'open_source_licenses_page.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _showContactDeveloperDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Contact Developer", style: blackPoppins),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sound Randomizer\nV 1.0.1\n", style: TextStyle(fontFamily: "Poppins"),),
              Text(
                  "Jika ada bug, fitur yang ingin ditambahkan, atau hal yang lain bisa kontak kami di email dibawah ini", style: TextStyle(fontFamily: "Poppins"),),
              SizedBox(height: 10),
              InkWell(
                child: Text(
                  "athilaramdani@gmail.com",
                  style: TextStyle(color: Colors.blue, fontFamily: "Poppins"),
                ),
                onTap: () {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'athilaramdani@gmail.com',
                    queryParameters: {
                      'subject': 'Feedback for Sound Randomizer'
                    },
                  );
                  _launchUrl(emailLaunchUri.toString());
                },
              ),
            Text(
              'Copyright © 2024 Athdanz Tech. All rights reserved.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
            ],
          ),
          actions: [
            TextButton(
              child: Text("Close"),
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
        title: Text(
          'About',
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            height: 2.0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  height: 2.0,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.code),
            title: Text(
              'Open-Source Licenses',
              style: TextStyle(
                fontFamily: "Poppins",
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OpenSourceLicensesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text(
              'Contact Developer',
              style: TextStyle(
                fontFamily: "Poppins",
              ),
            ),
            onTap: _showContactDeveloperDialog,
          ),
        ],
      ),
    );
  }
}
