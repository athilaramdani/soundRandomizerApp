import 'package:athdan2/ui/soundpack/soundpack_page.dart';
import 'package:flutter/material.dart';
import '../../function.dart'; // Sesuaikan dengan path ke file yang berisi primaryColor dan primaryTextStyle

class CategoryTile extends StatelessWidget {
  final String category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SoundPackPage(category: category),
          ),
        );
      },
      child: Card(
        color: primaryColor,
        child: ListTile(
          title: Text(
            category,
            style: primaryTextStyle,
          ),
          trailing: Wrap(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                color: Colors.white,
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Colors.white,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
