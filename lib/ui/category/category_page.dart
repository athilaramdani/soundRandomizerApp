import 'dart:io';
import 'dart:ui';
import 'package:athdan2/ui/category/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user/user_page.dart';
import '../../function.dart';
import 'package:url_launcher/url_launcher.dart';
import '../about/about_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<String> categories = [];
  String? username;
  String? email;
  String? profileImagePath;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCategories();
    _initBannerAd();
    MobileAds.instance.initialize(); // Inisialisasi Google Mobile Ads
  }

  @override
  void dispose() {
    _bannerAd.dispose();
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

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      profileImagePath = prefs.getString('profileImagePath');
    });
  }

  void _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCategories = prefs.getStringList('categories');
    if (savedCategories != null) {
      setState(() {
        categories = savedCategories;
      });
    }
  }

  void _saveCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('categories', categories);
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCategory = '';

        return AlertDialog(
          title: Text('Add Category', style: blackPoppins,),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(hintText: 'Enter category name'), style: TextStyle(fontFamily: "Poppins"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(fontFamily: "Poppins"),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor
              ),
              child: Text('Add', style: primaryTextStyle,),
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  setState(() {
                    categories.add(newCategory);
                    _saveCategories();
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editCategory(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedCategory = categories[index];

        return AlertDialog(
          title: Text('Edit Category', style: blackPoppins,),
          content: TextField(
            onChanged: (value) {
              updatedCategory = value;
            },
            controller: TextEditingController(text: categories[index]),
            decoration: InputDecoration(hintText: 'Enter category name'), style: TextStyle(fontFamily: "Poppins"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(fontFamily: "Poppins"),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor
              ),
              child: Text('Save', style: primaryTextStyle,),
              onPressed: () async {
                if (updatedCategory.isNotEmpty) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String oldCategory = categories[index];

                  // Get the sound packs associated with the old category name
                  List<String>? soundPacks = prefs.getStringList(oldCategory);

                  if (soundPacks != null) {
                    // Save the sound packs with the new category name
                    prefs.setStringList(updatedCategory, soundPacks);
                    // Remove the sound packs associated with the old category name
                    prefs.remove(oldCategory);
                  }

                  setState(() {
                    categories[index] = updatedCategory;
                    _saveCategories();
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category', style: blackPoppins,),
          content: Text('Are you sure you want to delete this category?', style: TextStyle(fontFamily: "Poppins"),),
          actions: [
            TextButton(
              child: Text('Cancel'),
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
                  categories.removeAt(index);
                  _saveCategories();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sound Randomizer',
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserPage()),
                  );
                  // Panggil _loadUserData lagi setelah kembali dari UserPage
                  _loadUserData();
                },
                child: Row(
                  children: [
                    if (profileImagePath != null)
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: FileImage(File(profileImagePath!)),
                      ),
                    if (profileImagePath == null)
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage('assets/images/user_avatar.png'),
                      ),
                    SizedBox(width: 8),
                    Text(
                      (username == null || username!.isEmpty) ? 'username' : username!,
                      style: headerBlackTextStyle,
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
            ],
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserPage()), // Arahkan ke user_page.dart
                );
              },
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: primaryColor,
                  image: profileImagePath != null
                      ? DecorationImage(
                    image: FileImage(File(profileImagePath!)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath!))
                      : AssetImage('assets/images/user_avatar.png') as ImageProvider,
                ),
                accountName: Text(
                  username ?? 'Your Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Poppins",
                  ),
                ),
                accountEmail: Text(
                  email ?? 'user@example.com',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                'About',
                style: TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text(
                'Donate Developer',
                style: TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              onTap: () async {
                const url = 'https://saweria.co/athilaramdani';
                await _launchUrl(url);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index < categories.length) {
                          return CategoryTile(
                            category: categories[index],
                            onEdit: () => _editCategory(index),
                            onDelete: () => _deleteCategory(index),
                          );
                        } else {
                          return ListTile(
                            title: Center(
                              child: IconButton(
                                icon: Icon(Icons.add, size: 40),
                                onPressed: _addCategory
                              )
                            )
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
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
    );
  }
}
