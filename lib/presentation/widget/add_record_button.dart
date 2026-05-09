import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/button_style.dart';

class AddRecordButton extends StatelessWidget {
  final FutureOr<void> Function(String name) onComplete;

  const AddRecordButton({ super.key, required this.onComplete });

  @override
  Widget build(BuildContext context)
    => ElevatedButton(
        style: elevatedButtonStyleThird,
        onPressed: () => _showDialog(context),
        child: const Text('新規追加'),
      );

  void _showDialog(BuildContext context) async {
    final controller = TextEditingController();
    final accept = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("新規追加"),
        content: SizedBox(
          width: 240,
          height: 50,
          child: Row(
            children: [
              Text('名前：'),
              Expanded(
                child: TextField(
                  controller: controller,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (accept == true) {
      await onComplete(controller.text);
    }
    controller.dispose();
  }
}