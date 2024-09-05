import 'package:app_emel_cm/pages/pages.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex].widget,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF2D5920),
        selectedItemColor: const Color(0xFFEFF2D5),
        unselectedItemColor: Colors.grey,
        items: pages
            .map((page) => BottomNavigationBarItem(
                icon: Icon(page.icon), label: page.title))
            .toList(),
      ),
    );
  }
}
