import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../function.dart';
import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SoundPage extends StatefulWidget {
  final String soundPackName;
  final String categoryName;

  SoundPage({required this.soundPackName, required this.categoryName});

  @override
  _SoundPageState createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  List<String> sounds = [];
  List<AudioPlayer> audioPlayers = [];
  final AudioPlayer audioPlayer = AudioPlayer();
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadSounds();
    _initBannerAd();
    MobileAds.instance.initialize();
  }

  void _loadSounds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSounds = prefs.getStringList(widget.soundPackName);
    if (savedSounds != null) {
      setState(() {
        sounds = savedSounds;
      });
    }
  }

  void stopAllSounds() async {
    for (var player in audioPlayers) {
      await player.stop();
    }
    audioPlayers.clear();
  }

  void _saveSounds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(widget.soundPackName, sounds);
  }

  void playSound(String path) async {
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: [AVAudioSessionOptions.mixWithOthers],
      ),
    ));
    audioPlayers.add(audioPlayer);
    await audioPlayer.play(DeviceFileSource(path));
  }

  void addSound(bool multiple) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: multiple,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav'],
    );

    if (result != null) {
      List<String> files = result.paths.whereType<String>().toList();
      setState(() {
        sounds.addAll(files);
        _saveSounds();
      });
      print('Files added: ${files.join(', ')}');
    } else {
      print('File picking cancelled or failed');
    }
  }

  void editSound(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Sound', style: blackPoppins,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor
                ),
                child: Text('Rename Sound', style: primaryTextStyle,),
                onPressed: () async {
                  Navigator.of(context).pop();

                  String newName = await _showRenameDialog(sounds[index]);
                  if (newName.isNotEmpty) {
                    String? newPath = await renameSound(sounds[index], newName);
                    if (newPath != null) {
                      setState(() {
                        sounds[index] = newPath;
                        _saveSounds();
                      });
                    }
                  }
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor
                ),
                child: Text('Crop Sound',style: primaryTextStyle),
                onPressed: () async {
                  Navigator.of(context).pop();

                  await _showCropDialog(sounds[index], index);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor
                ),
                child: Text('Save Sound',style: primaryTextStyle),
                onPressed: () async {
                  await saveSound(sounds[index]);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteSound(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Sound', style: blackPoppins,),
          content: Text('Are you sure you want to delete this sound?', style: TextStyle(fontFamily: "Poppins"),),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(fontFamily: "Poppins"),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor
              ),
              child: Text('Delete', style: primaryTextStyle,),
              onPressed: () {
                setState(() {
                  sounds.removeAt(index);
                  _saveSounds();
                });
                Navigator.of(context).pop();
                print('File deleted at index: $index');
              },
            ),
          ],
        );
      },
    );

  }

  @override
  void dispose() {
    _bannerAd.dispose();
    stopAllSounds();
    super.dispose();
  }
  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5535790739671639/1682836778', // ID unit iklan uji
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName + "/" + widget.soundPackName,
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: stopAllSounds,
          ),
        ],
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: sounds.length + 1,
                itemBuilder: (context, index) {
                  if (index == sounds.length) {
                    return ListTile(
                      title: Center(
                        child: IconButton(
                          icon: Icon(Icons.add, size: 40),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Add Sound', style: blackPoppins,),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor2
                                        ),
                                        child: Text('Add Single File', style: primaryTextStyle,),
                                        onPressed: () {
                                          addSound(false);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor
                                        ),
                                        child: Text('Add Multiple Files', style: primaryTextStyle,),
                                        onPressed: () {
                                          addSound(true);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    String fileName = sounds[index].split('/').last;
                    return Card(
                      color: primaryColor,
                      child: ListTile(
                        title: Text(
                          fileName,
                          style: primaryTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.white),
                          onPressed: () => playSound(sounds[index]),
                        ),
                        onTap: () => playSound(sounds[index]),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () => editSound(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () => deleteSound(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            if (_isBannerAdReady)
              Container(
                height: _bannerAd.size.height.toDouble(),
                width: _bannerAd.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
          ],
        ),
      ),
    );
  }

  Future<String> _showRenameDialog(String currentName) async {
    TextEditingController controller = TextEditingController(text: currentName.split('/').last);
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename Sound', style: blackPoppins,),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new name"), style: TextStyle(fontFamily: "Poppins"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL', style: TextStyle(fontFamily: "Poppins"),),
              onPressed: () {
                Navigator.of(context).pop('');
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: primaryColor
              ),
              child: Text('RENAME', style: primaryTextStyle,),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    ) ?? '';
  }

  Future<void> _showCropDialog(String soundPath, int index) async {
    double startTime = 0.0;
    double endTime = 10.0; // Default end time

    Duration? audioDuration = await _getAudioDuration(soundPath);

    if (audioDuration != null) {
      endTime = audioDuration.inSeconds.toDouble();
    }

    TextEditingController startController = TextEditingController(text: startTime.toString());
    TextEditingController endController = TextEditingController(text: endTime.toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Crop Sound', style: blackPoppins,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startController,
                decoration: InputDecoration(labelText: 'Start Time (seconds)'), style: TextStyle(fontFamily: "Poppins"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: endController,
                decoration: InputDecoration(labelText: 'End Time (seconds)'), style: TextStyle(fontFamily: "Poppins"),
                keyboardType: TextInputType.number
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL', style: TextStyle(fontFamily: "Poppins"),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: primaryColor
              ),
              child: Text('CROP',style: primaryTextStyle,),
              onPressed: () async {
                startTime = double.tryParse(startController.text) ?? 0.0;
                endTime = double.tryParse(endController.text) ?? 0.0;

                if (startTime < endTime) {
                  String? croppedPath = await cropAudio(soundPath, startTime, endTime);
                  if (croppedPath != null) {
                    setState(() {
                      sounds[index] = croppedPath;
                      _saveSounds();
                    });
                    Navigator.of(context).pop();
                  } else {
                    // Show an error message
                    print('Error: croppedPath is null');
                  }
                } else {
                  // Show an error message
                  print('Error: Start time is greater than or equal to end time');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<Duration?> _getAudioDuration(String path) async {
    try {
      await audioPlayer.setSource(DeviceFileSource(path));
      return await audioPlayer.getDuration();
    } catch (e) {
      print('Error getting audio duration: $e');
      return null;
    }
  }
}
