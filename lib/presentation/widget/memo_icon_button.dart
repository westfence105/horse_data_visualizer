import 'dart:async';

import 'package:flutter/material.dart';

class MemoIconButton extends StatefulWidget {
  final String name;
  final String? content;
  final FutureOr<void> Function(String memo) onChange;

  const MemoIconButton({
      required this.name,
      required this.content,
      required this.onChange,
      super.key,
    });

  @override
  State<StatefulWidget> createState() => _MemoIconButtonState();
}

class _MemoIconButtonState extends State<MemoIconButton> {
  late String? content;

  @override
  void initState() {
    super.initState();
    content = widget.content;
  }

  @override
  Widget build(BuildContext context) {
    late Widget icon;
    if (content == null) {
      icon = Icon(
        Icons.sticky_note_2_outlined,
        color: Colors.grey,
      );
    }
    else {
      icon = Tooltip(
        message: content!,
        textStyle: TextStyle(
          fontSize: 16,
        ),
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Icon(
          Icons.sticky_note_2_outlined,
        ),
      );
    }
    return IconButton(
      onPressed: () {
        final controller = TextEditingController();
        if (content != null) {
          controller.text = content!;
        }
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('メモ編集 (${widget.name})'),
            titleTextStyle: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
            content: SizedBox(
              width: 240,
              height: 50,
              child: Row(
                children: [
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
        ).then((accept) {
          if (accept == true && content != controller.text) {
            setState(() {
              content = controller.text;
            });
            widget.onChange(controller.text);
          }
          controller.dispose();
        });
      },
      icon: icon,
    );
  }
}
