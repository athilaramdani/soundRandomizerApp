import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

const Color primaryColor = Color(0xFF256FFF);
const Color primaryColor2 = Color(0xFF4785FF);
const Color dangerColor = Color(0xFFf50000);

const TextStyle primaryTextStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'Inter',
  fontWeight: FontWeight.bold,
);

const TextStyle inversPrimaryTextStyle = TextStyle(
  color: primaryColor,
  fontFamily: 'Inter',
  fontWeight: FontWeight.bold,
);

const TextStyle primaryPoppins = TextStyle(
  color: primaryColor,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.bold,
);

const TextStyle headerBlackTextStyle = TextStyle(
  color: Colors.black,
  fontFamily: 'Inter',
  fontWeight: FontWeight.bold,
);

const TextStyle blackPoppins = TextStyle(
  color: Colors.black,
  fontFamily: 'Inter',
  fontWeight: FontWeight.bold,
);

Future<String?> renameSound(String filePath, String newFileName) async {
  try {
    final directory = Directory(filePath).parent;
    String newPath = '${directory.path}/$newFileName';
    File file = File(filePath);
    await file.rename(newPath);
    return newPath;
  } catch (e) {
    print('Error while renaming sound: $e');
    return null;
  }
}

Future<String?> cropAudio(String filePath, double start, double end) async {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  Directory directory = await getApplicationDocumentsDirectory();

  // Dapatkan ekstensi file asli
  String fileExtension = path.extension(filePath);
  String outputPath = '${directory.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

  // Cek apakah file input ada
  if (!await File(filePath).exists()) {
    print('Error: Input file does not exist');
    return null;
  }

  try {
    int rc = await _flutterFFmpeg.execute(
        '-i "$filePath" -ss $start -to $end -c copy "$outputPath"'
    );

    if (rc == 0 && await File(outputPath).exists()) {
      return outputPath;
    } else {
      print('FFmpeg process failed with return code $rc');
      return null;
    }
  } catch (e) {
    print('Error while cropping audio: $e');
    return null;
  }
}


Future<void> saveSound(String filePath) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  if (selectedDirectory != null) {
    try {
      File file = File(filePath);
      String fileName = file.path.split('/').last;
      String newPath = '$selectedDirectory/$fileName';
      await file.copy(newPath);
      print('Sound saved to: $newPath');
    } catch (e) {
      print('Error while saving sound: $e');
    }
  } else {
    print('No directory selected');
  }
}