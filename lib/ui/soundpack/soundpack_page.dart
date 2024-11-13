import 'package:flutter/material.dart';
import 'sound_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import '../../function.dart';
import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SoundPackPage extends StatefulWidget {
  final String category;

  SoundPackPage({required this.category});

  @override
  _SoundPackPageState createState() => _SoundPackPageState();
}

class _SoundPackPageState extends State<SoundPackPage> {
  List<String> soundPacks = [];
  final Random random = Random();
  final List<AudioPlayer> _audioPlayers = [];
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadSoundPacks();
    _initBannerAd();
    _initInterstitialAd();
    MobileAds.instance.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
    _interstitialAd?.dispose();
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

  void _initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-5535790739671639/8993354736', // ID unit iklan uji
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
      _initInterstitialAd();
    }
  }

  void _loadSoundPacks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSoundPacks = prefs.getStringList(widget.category);
    if (savedSoundPacks != null) {
      setState(() {
        soundPacks = savedSoundPacks;
      });
    }
  }

  void _saveSoundPacks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(widget.category, soundPacks);
  }

  Future<void> playRandomSound(String soundPackName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? sounds = prefs.getStringList(soundPackName);

    if (sounds != null && sounds.isNotEmpty) {
      String randomSound = sounds[random.nextInt(sounds.length)];
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
      _audioPlayers.add(audioPlayer);
      await audioPlayer.play(DeviceFileSource(randomSound));
    } else {
      print('No sounds available to play in $soundPackName');
    }
  }

  void stopSound() async {
    for (var player in _audioPlayers) {
      await player.stop();
    }
    _audioPlayers.clear();
  }

  void addSoundPack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newSoundPackName = '';
        return AlertDialog(
          title: Text('Add New Sound Pack', style: blackPoppins,),
          content: TextField(
            onChanged: (value) {
              newSoundPackName = value;
            },
            decoration: InputDecoration(hintText: "Name your sound pack..."),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(fontFamily: "Poppins"),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: Text('Add', style: primaryTextStyle,),
              onPressed: () {
                setState(() {
                  soundPacks.add(newSoundPackName);
                  _saveSoundPacks();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void editSoundPack(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedSoundPackName = soundPacks[index];
        return AlertDialog(
          title: Text('Edit Sound Pack', style: blackPoppins,),
          content: TextField(
            onChanged: (value) {
              updatedSoundPackName = value;
            },
            decoration: InputDecoration(hintText: "Name your sound pack..."), style: TextStyle(fontFamily: "Poppins"),
            controller: TextEditingController(text: soundPacks[index]),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(fontFamily: "Poppins"),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: primaryColor
              ),
              child: Text('Update', style: primaryTextStyle),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String oldSoundPackName = soundPacks[index];

                // Get the sounds associated with the old name
                List<String>? sounds = prefs.getStringList(oldSoundPackName);

                if (sounds != null) {
                  // Save the sounds with the new name
                  prefs.setStringList(updatedSoundPackName, sounds);
                  // Remove the sounds associated with the old name
                  prefs.remove(oldSoundPackName);
                }

                setState(() {
                  soundPacks[index] = updatedSoundPackName;
                  _saveSoundPacks();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteSoundPack(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Sound Pack', style: blackPoppins,),
          content: Text('Are you sure you want to delete this sound pack?', style: TextStyle(fontFamily: "Poppins"),),
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
                  String soundPackName = soundPacks[index];
                  soundPacks.removeAt(index);
                  _saveSoundPacks();
                  stopSound();
                });
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
    int crossAxisCount;
    if (MediaQuery.of(context).size.width > 1200) {
      crossAxisCount = 10;
    } else if (MediaQuery.of(context).size.width > 600) {
      crossAxisCount = 6;
    } else if (MediaQuery.of(context).size.width > 280){
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }
    return WillPopScope(
      onWillPop: () async {
        _showInterstitialAd();
        return true; // return true to allow the back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.category,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
              fontSize: (18.0),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: stopSound,
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
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: soundPacks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == soundPacks.length) {
                      return GestureDetector(
                        onTap: addSoundPack,
                        child: Card(
                          child: Center(
                            child: Icon(Icons.add, size: 40),
                          ),
                        ),
                      );
                    } else {
                      return Card(
                        color: primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SoundPage(
                                        soundPackName: soundPacks[index],
                                        categoryName: widget.category,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffd8ecff),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  padding: EdgeInsets.all(6.0),
                                  child: Text(
                                    soundPacks[index],
                                    style: inversPrimaryTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              IconButton(
                                icon: Icon(Icons.play_arrow, color: Colors.white),
                                onPressed: () =>
                                    playRandomSound(soundPacks[index]),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      onPressed: () => editSoundPack(index),
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      icon:
                                      Icon(Icons.delete, color: Colors.white),
                                      onPressed: () => deleteSoundPack(index),
                                    ),
                                  ),
                                ],
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
      ),
    );
  }
}
