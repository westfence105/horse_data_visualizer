import 'package:flutter/material.dart';

void updateTextEditingControllerMap(Map<String,TextEditingController> map, String key, String value) {
  if (map.containsKey(key)) {
    map[key]!.text = value;
  }
  else {
    map[key] = TextEditingController(text: value);
  }
}

void updateNotifierMap<T>(Map<String,ValueNotifier<T>> map, String key, T value) {
  if (map.containsKey(key)) {
    map[key]!.value = value;
  }
  else {
    map[key] = ValueNotifier(value);
  }
}

bool Function(String,ChangeNotifier) testAndDispose(Set<String> validKeys)
  =>(String k, ChangeNotifier v) {
    if (!validKeys.contains(k)) {
      v.dispose();
      return true;
    }
    else {
      return false;
    }
  };

void disposeAll(Iterable<ChangeNotifier> notifiers) {
  for(final v in notifiers) {
    v.dispose();
  }
}
