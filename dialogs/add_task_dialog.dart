import 'package:flutter/material.dart';

Future<String?> showAddTaskDialog(BuildContext context, {String? initialTitle}) {
  final TextEditingController controller = TextEditingController(text: initialTitle);

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(initialTitle == null ? 'Add New Task' : 'Edit Task'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Task Title'),
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

Future<bool> showAddMoreTasksDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add More Tasks'),
        content: Text('Do you want to add more tasks to this list?'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );

  return result ?? false;
}
