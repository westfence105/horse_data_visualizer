import 'package:flutter/material.dart';

import '../../data/service/store/mare_name_store.dart';
import '../misc/string_extension.dart';

class MareNameInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function(String value)? onChanged;

  const MareNameInput({
    super.key,
    required this.textEditingController,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context)
    => Autocomplete<String>(
        textEditingController: textEditingController,
        focusNode: FocusNode(),
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