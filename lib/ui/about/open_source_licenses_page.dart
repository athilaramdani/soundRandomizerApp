import 'package:flutter/material.dart';
import 'dart:ui';

class OpenSourceLicensesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Open-Source Licenses',
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
            title: Text(
              'FFmpeg',
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'FFmpeg by Fabrice Bellard and many contributors\n'
                  'Copyright (c) 2000-2023 the FFmpeg developers\n'
                  'Licensed under the LGPLv2.1.\n'
                  'Source: https://ffmpeg.org/',
              style: TextStyle(
                fontFamily: "Poppins",
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Shared Preferences',
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Shared Preferences by the Flutter team\n'
                  'Copyright (c) 2014-2023 The Flutter Authors\n'
                  'Licensed under the BSD 3-Clause License.',
              style: TextStyle(
                fontFamily: "Poppins",
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Audioplayers',
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Audioplayers by BlueFireTeam\n'
                  'Copyright (c) 2018-2023 BlueFireTeam\n'
                  'Licensed under the MIT License.',
              style: TextStyle(
                fontFamily: "Poppins",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
