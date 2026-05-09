import 'package:flutter/material.dart';

import '../../data/service/store/mare_name_store.dart';
import '../misc/string_extension.dart';

class MareNameInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function(String value)? onChanged;

  const MareNameInput({
    super.key,
    required this.textEditingController,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _MareNameInputState();
}

class _MareNameInputState extends State<MareNameInput> {
  TextEditingController get textEditingController => widget.textEditingController;
  Function(String value)? get onChanged => widget.onChanged;

  final focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context)
    => Autocomplete<String>(
        textEditingController: textEditingController,
        focusNode: focusNode,
        optionsBuilder: (value) async
          => (await mareNameStore.names).where(
                (s) => s.startsWith(value.text.toKatakana()),
              ),
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted)
          => TextField(
            controller: textEditingController,
            focusNode: focusNode,
            onSubmitted: (_) => onFieldSubmitted(),
            onChanged: onChanged,
          ),
        onSelected: (option) {
          if (onChanged != null) onChanged!(option);
        },
      );
}