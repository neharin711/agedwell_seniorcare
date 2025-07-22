
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  final int currentIndex;
  const CustomNavigationBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    List<String> navItems = [
      // HomePageIndividual.routeName,
      // postfeed.routeName,
      // UserChatsScreen.routeName,
      // IndividualInfoPage.routeName,
    ];

    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 22, 115, 121),
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: widget.currentIndex,
        onTap: ((value) {
          if (value != widget.currentIndex) {
            Navigator.of(context).pushReplacementNamed(
              navItems[value],
            );
          }
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Color(0xFFC7E2E4),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: "Add",
            backgroundColor: Color(0xFFC7E2E4),
          ),
          BottomNavigationBarItem(
            tooltip: "Chat With Admin",
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chats",
            backgroundColor: Color(0xFFC7E2E4),

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
            backgroundColor: Color(0xFFC7E2E4),
          ),
        ]);
  }
}
