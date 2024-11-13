import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../function.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  String? _profileImagePath;
  bool _isEditing = false;
  bool _hasUnsavedChanges = false;
  late String initialName;
  late String initialUsername;
  late String initialEmail;
  late String initialBirthday;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? 'Your Name';
      _usernameController.text = prefs.getString('username') ?? 'Username';
      _emailController.text = prefs.getString('email') ?? 'user@example.com';
      _birthdayController.text = prefs.getString('birthday') ?? '01/01/2000';
      _profileImagePath = prefs.getString('profileImagePath');
      initialName = _nameController.text;
      initialUsername = _usernameController.text;
      initialEmail = _emailController.text;
      initialBirthday = _birthdayController.text;
    });
  }

  void _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('birthday', _birthdayController.text);
    if (_profileImagePath != null) {
      await prefs.setString('profileImagePath', _profileImagePath!);
    }
    setState(() {
      _hasUnsavedChanges = false;
      initialName = _nameController.text;
      initialUsername = _usernameController.text;
      initialEmail = _emailController.text;
      initialBirthday = _birthdayController.text;
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profileImagePath', image.path);
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      bool? shouldSave = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsaved Changes', style: blackPoppins,),
          content: Text('You have unsaved changes. Do you want to save them?', style: TextStyle(fontFamily: "Poppins"),),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: dangerColor
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No', style: primaryTextStyle,),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: primaryColor
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes', style: primaryTextStyle,),
            ),
          ],
        ),
      );

      if (shouldSave == true) {
        _saveUserData();
      } else {
        _nameController.text = initialName;
        _usernameController.text = initialUsername;
        _emailController.text = initialEmail;
        _birthdayController.text = initialBirthday;
        Navigator.of(context).pop(true);
      }
      return shouldSave ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.day}/${picked.month}/${picked.year}";
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sound Randomizer',
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveUserData();
                }
                _toggleEditMode();
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              height: 1.0,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : AssetImage('assets/images/user_avatar.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 20),
                _buildEditableField(_nameController, 'Your Name'),
                SizedBox(height: 10),
                _buildEditableField(_emailController, 'user@example.com'),
                SizedBox(height: 20),
                _buildEditableField(_usernameController, 'Username'),
                SizedBox(height: 20),
                _buildDateField(_birthdayController, '01/01/2000'),
                if (_isEditing)
                  SizedBox(height: 20),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: () {
                      _saveUserData();
                      _toggleEditMode();
                    },
                    child: Text('Save Changes', style: primaryTextStyle),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontWeight: FontWeight.normal),
        border: OutlineInputBorder(),
      ),
      style: TextStyle(fontWeight: FontWeight.normal),
      enabled: _isEditing,
      onChanged: (value) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      },
    );
  }

  Widget _buildDateField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontWeight: FontWeight.normal),
        border: OutlineInputBorder(),
      ),
      style: TextStyle(fontWeight: FontWeight.normal),
      enabled: _isEditing,
      onTap: _isEditing ? () => _selectDate(context) : null,
      readOnly: true,
    );
  }
}
