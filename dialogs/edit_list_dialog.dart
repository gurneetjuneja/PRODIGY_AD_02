import 'package:flutter/material.dart';

Future<String?> showEditListDialog(BuildContext context, String currentTitle) {
  final TextEditingController controller = TextEditingController(text: currentTitle);

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit List Title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'List Title'),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          ),
        ],
      );
    },
  );
}
