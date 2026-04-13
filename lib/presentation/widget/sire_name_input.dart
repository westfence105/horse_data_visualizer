import 'package:flutter/material.dart';

import '../../data/service/store/sire_name_store.dart';
import '../misc/string_extension.dart';

class SireNameInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function(String value)? onChanged;

  const SireNameInput({
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