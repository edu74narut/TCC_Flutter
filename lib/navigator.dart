import 'package:flutter/material.dart';
import 'about.dart';
import 'profile.dart';
import 'home.dart';

class MainNavigator extends StatefulWidget {
  final List<String> usuario;

  const MainNavigator({super.key, required this.usuario});

  @override
  MainNavigatorState createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      const Home(),
      ProfilePage(usuario: widget.usuario),
      About(),
    ];

    return SafeArea(
      child: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            BottomNavigationBarItem(
                icon: Icon(Icons.info), label: 'Sobre nós'),
          ],
          onTap: (i) {
            setState(() {
              selectedIndex = i;
            });
          },
          currentIndex: selectedIndex,
        ),
      ),
    );
  }
}