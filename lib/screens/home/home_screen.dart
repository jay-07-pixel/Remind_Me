import 'package:flutter/material.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/screens/contacts/contacts_screen.dart';
import 'package:remind_me/screens/home/home_dashboard.dart';
import 'package:remind_me/screens/settings/settings_tab_screen.dart';
import 'package:remind_me/widgets/app_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    HomeDashboard(),
    ContactsScreen(),
    SettingsTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
