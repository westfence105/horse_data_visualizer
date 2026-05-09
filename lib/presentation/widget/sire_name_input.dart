import 'package:flutter/material.dart';

import '../../data/service/store/sire_name_store.dart';
import '../misc/string_extension.dart';

class SireNameInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function(String value)? onChanged;

  const SireNameInput({
    super.key,
    required this.textEditingController,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _SireNameInputState();
}

class _SireNameInputState extends State<SireNameInput> {
  TextEditingController get textEditingController => widget.textEditingController;
  Function(String value)? get onChanged => widget.onChanged;

  final focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
    => Autocomplete<String>(
        textEditingController: textEditingController,
        focusNode: focusNode,
        optionsBuilder: (value) async
          => (await sireNameStore.names).where(
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