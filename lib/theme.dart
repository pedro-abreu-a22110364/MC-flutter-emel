import 'package:app_emel_cm/contants.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: colorPrimary,
    appBarTheme: const AppBarTheme(
        backgroundColor: colorSecondary,
        foregroundColor: colorPrimary,
        elevation: 2),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: Colors.grey[800],
        fontSize: 20,
        fontWeight: FontWeight.w800,
        fontFamily: 'OpenSans',
      ),
      displayMedium: TextStyle(
        color: Colors.grey[800],
        fontSize: 15,
        fontWeight: FontWeight.w700,
        fontFamily: 'OpenSans',
      ),
      displaySmall: TextStyle(
        color: Colors.grey[800],
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'OpenSans',
      ),
    ));
