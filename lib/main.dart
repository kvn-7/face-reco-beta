import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  runApp(MaterialApp(
    themeMode: ThemeMode.light,
    theme: ThemeData(brightness: Brightness.light),
    home: HomePage(),
    title: "Face Recognition",
    debugShowCheckedModeBanner: false,
  ));
}
