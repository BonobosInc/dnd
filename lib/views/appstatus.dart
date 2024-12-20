import 'package:dnd/configs/colours.dart';
import 'package:flutter/material.dart';

class AppStatusDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onImageTap;

  const AppStatusDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: GestureDetector(
        onTap: onImageTap,
        child: Text(
          content,
          style: TextStyle(
            color: AppColors.textColorDark,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Schließen'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

void showAppStatusDialog(BuildContext context) {
  String version = "1.0.0";

  String content = "Für Bonobos, von Bonobos\nVersion: $version\n";

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AppStatusDialog(
        title: 'BonoDND',
        content: content,
        onImageTap: () {
          _showImageDialog(context);
        },
      );
    },
  );
}

void _showImageDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image.asset(
            'assets/images/bonobo.png',
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
      );
    },
  );
}
