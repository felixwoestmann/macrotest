import 'dart:convert';

import 'package:macrotest/data_class.dart';

@DataClass()
class Bar {
  final int x;
  final String y;
  final List<String> z;
}

void main() {
  final bar = Bar(x: 1, y: 'hello', z: ['1','2', '3']);
  final text = bar.toString();
  final json = jsonEncode(bar.toJson());
  print(json);
  final bar2 = Bar.fromJson(jsonDecode(json));
}
